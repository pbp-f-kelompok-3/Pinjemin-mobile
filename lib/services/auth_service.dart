import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../models/profile.dart';

const String kBaseUrl = 'https://roisul-umam-pinjemin.pws.cs.ui.ac.id';

/// Error with a message that is safe to show to the user as-is.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

const String kNetworkErrorMessage =
    'Tidak bisa terhubung ke server. Cek koneksimu lalu coba lagi.';
const String kBadResponseMessage =
    'Server memberi jawaban yang tidak dikenali. Coba lagi beberapa saat.';

/// Returns the SSO ticket when [url] is the mobile callback URL, otherwise null.
String? ticketFromCallbackUrl(String url, String callbackPrefix) {
  if (!url.startsWith(callbackPrefix)) return null;
  final ticket = Uri.parse(url).queryParameters['ticket'];
  if (ticket == null || ticket.isEmpty) return null;
  return ticket;
}

/// Wraps [CookieRequest] for the /akun/api/ endpoints.
///
/// Every POST carries the X-CSRFToken header (copied from the csrftoken cookie)
/// and an Origin header, because Django checks the origin on HTTPS requests and
/// Dart's http client, unlike a browser, does not send one by itself.
class AuthService {
  AuthService(this.request, {this.baseUrl = kBaseUrl});

  final CookieRequest request;
  final String baseUrl;

  String get callbackPrefix => '$baseUrl/akun/api/sso/callback/';

  void syncCsrfHeaders() {
    final token = request.cookies['csrftoken']?.value;
    if (token != null) {
      request.headers['X-CSRFToken'] = token;
    }
    request.headers['Origin'] = baseUrl;
  }

  /// Runs a CookieRequest call and turns transport and format failures into [ApiException].
  Future<Map<String, dynamic>> _call(Future<dynamic> Function() send) async {
    final dynamic data;
    try {
      data = await send();
    } on FormatException {
      // An HTML page (404, server error) instead of the API's JSON
      throw const ApiException(kBadResponseMessage);
    } on Exception {
      throw const ApiException(kNetworkErrorMessage);
    }
    if (data is! Map<String, dynamic>) {
      throw const ApiException(kNetworkErrorMessage);
    }
    return data;
  }

  Map<String, dynamic> _requireSuccess(Map<String, dynamic> data) {
    if (data['status'] != true) {
      throw ApiException(
        data['message'] as String? ?? 'Terjadi kesalahan. Coba lagi.',
      );
    }
    return data;
  }

  /// Step 1 of login: asks the server for the SSO UI URL (this also sets csrftoken).
  Future<String> fetchLoginUrl() async {
    final data = _requireSuccess(
      await _call(() => request.get('$baseUrl/akun/api/sso/start/')),
    );
    return data['login_url'] as String;
  }

  /// Step 2 of login: trades the SSO ticket for a Django session.
  Future<Profile> exchangeTicket(String ticket) async {
    syncCsrfHeaders();
    final data = _requireSuccess(
      await _call(
        () => request.login(
          '$baseUrl/akun/api/sso/exchange/',
          {'ticket': ticket},
        ),
      ),
    );
    // Django rotates the CSRF token on login, so copy the new one
    syncCsrfHeaders();
    return Profile.fromJson(data['profile']);
  }

  /// Checks the session stored on the device. Returns null when there is none
  /// or the server says it has expired.
  Future<Profile?> restoreSession() async {
    await request.init();
    if (!request.loggedIn) return null;

    final data = await _call(() => request.get('$baseUrl/akun/api/me/'));
    if (data['status'] != true) {
      await clearLocalSession();
      return null;
    }
    syncCsrfHeaders();
    return Profile.fromJson(data['profile']);
  }

  /// Forgets the session on this device, including the copy in SharedPreferences.
  Future<void> clearLocalSession() async {
    request.cookies = {};
    request.headers.remove('cookie');
    request.headers.remove('X-CSRFToken');
    request.loggedIn = false;
    request.jsonData = {};
    await request.persist('{}');
  }
}
