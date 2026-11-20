import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinjemin_mobile/main.dart';
import 'package:pinjemin_mobile/models/profile.dart';
import 'package:pinjemin_mobile/services/auth_service.dart';
import 'package:pinjemin_mobile/services/session_provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Call from setUpAll in every test file: fonts come from assets only.
void setUpTestEnvironment() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// One recorded call made through [FakeCookieRequest].
class RecordedCall {
  RecordedCall(this.method, this.url, this.body, this.headers);

  final String method;
  final String url;
  final dynamic body;
  final Map<String, String> headers;
}

typedef FakeResponder = dynamic Function(RecordedCall call);

/// CookieRequest with the network replaced by [responders], keyed by
/// "METHOD path" (for example "GET /akun/api/me/"). Cookies, headers and
/// SharedPreferences behave like the real class.
class FakeCookieRequest extends CookieRequest {
  FakeCookieRequest({Map<String, FakeResponder>? responders})
      : responders = responders ?? {};

  final Map<String, FakeResponder> responders;
  final List<RecordedCall> calls = [];

  /// Cookies the "server" sets on the next response, like Set-Cookie.
  Map<String, String> setCookiesOnNextResponse = {};

  dynamic _respond(String method, String url, dynamic body) {
    final path = Uri.parse(url).path;
    final call = RecordedCall(method, url, body, Map.of(headers));
    calls.add(call);
    final responder = responders['$method $path'];
    if (responder == null) {
      throw StateError('No fake response for $method $path');
    }
    final result = responder(call);
    setCookiesOnNextResponse.forEach((name, value) {
      cookies[name] = Cookie(name, value, null);
    });
    setCookiesOnNextResponse = {};
    return result;
  }

  @override
  Future<dynamic> get(String url) async {
    await init();
    return _respond('GET', url, null);
  }

  @override
  Future<dynamic> post(String url, dynamic data) async {
    await init();
    return _respond('POST', url, data);
  }

  @override
  Future<dynamic> login(String url, dynamic data) async {
    await init();
    final result = _respond('POST', url, data);
    loggedIn = result is Map && result['status'] == true;
    if (loggedIn) jsonData = Map<String, dynamic>.from(result);
    return result;
  }
}

/// Stores a session cookie in SharedPreferences, as left by an earlier login.
void mockStoredSession({bool loggedIn = true}) {
  final cookies = loggedIn
      ? {
          'sessionid': {'name': 'sessionid', 'value': 'abc', 'expireTimestamp': null},
          'csrftoken': {'name': 'csrftoken', 'value': 'stored-token', 'expireTimestamp': null},
        }
      : <String, dynamic>{};
  SharedPreferences.setMockInitialValues({'cookies': jsonEncode(cookies)});
}

Map<String, dynamic> profileJson({
  String fullName = 'Roisul Umam',
  String mode = 'renter',
  bool isOnboarded = true,
}) {
  final seller = mode == 'seller';
  return {
    'id': 7,
    'username': 'roisul.umam',
    'npm': '2506620210',
    'full_name': fullName,
    'kode_org': '01.00.12.01',
    'angkatan': 2025,
    'phone': '08123456789',
    'bio': 'Suka kucing.',
    'location': 'Kantin Fasilkom',
    'photo_url': null,
    'mode': mode,
    'mode_label': seller ? 'Minjemin' : 'Minjem',
    'is_seller': seller,
    'is_onboarded': isOnboarded,
    'completeness': {
      'percent': 75,
      'checks': [
        {'label': 'Foto profil', 'done': false},
        {'label': 'Nomor WhatsApp', 'done': true},
        {'label': 'Titik temu favorit', 'done': true},
        {'label': 'Bio singkat', 'done': true},
      ],
    },
    'created_at': '2026-11-01T08:00:00+07:00',
  };
}

Profile sampleProfile({String mode = 'renter', String fullName = 'Roisul Umam'}) =>
    Profile.fromJson(profileJson(mode: mode, fullName: fullName));

String api(String path) => '$kBaseUrl$path';

/// Wraps [child] in the app theme and the same providers as the real app.
Widget wrapWithApp(
  Widget child, {
  required CookieRequest request,
  SessionProvider? session,
}) {
  return MultiProvider(
    providers: [
      Provider<CookieRequest>.value(value: request),
      ChangeNotifierProvider<SessionProvider>.value(
        value: session ?? SessionProvider(),
      ),
    ],
    child: MaterialApp(theme: PinjeminTheme.build(), home: child),
  );
}

/// Pumps until all fonts and futures settle.
Future<void> pumpSettled(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Lets real async work (SharedPreferences, futures) finish inside widget tests.
Future<void> flush(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

Matcher throwsApiException(String message) => throwsA(
      isA<ApiException>().having((e) => e.message, 'message', message),
    );
