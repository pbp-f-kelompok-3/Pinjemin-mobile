import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fakes.dart';

void main() {
  const callback = '$kBaseUrl/akun/api/sso/callback/';

  setUp(() => mockStoredSession(loggedIn: false));

  group('ticketFromCallbackUrl', () {
    test('reads the ticket from the callback URL', () {
      expect(ticketFromCallbackUrl('$callback?ticket=ST-123', callback), 'ST-123');
    });

    test('ignores other URLs', () {
      expect(ticketFromCallbackUrl('https://sso.ui.ac.id/cas2/login', callback), isNull);
      expect(
        ticketFromCallbackUrl('https://evil.example/akun/api/sso/callback/?ticket=ST-1', callback),
        isNull,
      );
    });

    test('ignores a callback without a ticket', () {
      expect(ticketFromCallbackUrl(callback, callback), isNull);
      expect(ticketFromCallbackUrl('$callback?ticket=', callback), isNull);
    });
  });

  test('ApiException shows its message', () {
    expect(const ApiException('Gagal.').toString(), 'Gagal.');
  });

  group('fetchLoginUrl', () {
    test('returns the SSO URL', () async {
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/sso/start/': (_) => {
              'status': true,
              'login_url': 'https://sso.ui.ac.id/cas2/login?service=x',
            },
      });
      final auth = AuthService(request);

      expect(await auth.fetchLoginUrl(), 'https://sso.ui.ac.id/cas2/login?service=x');
      expect(request.calls.single.url, api('/akun/api/sso/start/'));
      expect(auth.callbackPrefix, callback);
    });

    test('shows the server message on failure', () {
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/sso/start/': (_) => {'status': false, 'message': 'Server sibuk.'},
      });
      expect(AuthService(request).fetchLoginUrl(), throwsApiException('Server sibuk.'));
    });

    test('uses a default message when the server gives none', () {
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/sso/start/': (_) => {'status': false},
      });
      expect(
        AuthService(request).fetchLoginUrl(),
        throwsApiException('Terjadi kesalahan. Coba lagi.'),
      );
    });

    test('maps a network failure to a friendly message', () {
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/sso/start/': (_) => throw const SocketException('offline'),
      });
      expect(AuthService(request).fetchLoginUrl(), throwsApiException(kNetworkErrorMessage));
    });

    test('maps an HTML answer (404, server error) to a friendly message', () {
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/sso/start/': (_) => jsonDecode('<html>403</html>'),
      });
      expect(AuthService(request).fetchLoginUrl(), throwsApiException(kBadResponseMessage));
    });

    test('rejects a body that is not a JSON object', () {
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/sso/start/': (_) => ['unexpected'],
      });
      expect(AuthService(request).fetchLoginUrl(), throwsApiException(kNetworkErrorMessage));
    });
  });

  group('exchangeTicket', () {
    test('sends the ticket with CSRF and Origin headers, then takes the rotated token', () async {
      final request = FakeCookieRequest();
      request.responders['GET /akun/api/sso/start/'] = (_) {
        request.setCookiesOnNextResponse = {'csrftoken': 'token-before'};
        return {'status': true, 'login_url': 'https://sso.ui.ac.id/cas2/login'};
      };
      request.responders['POST /akun/api/sso/exchange/'] = (_) {
        request.setCookiesOnNextResponse = {
          'sessionid': 'session-1',
          'csrftoken': 'token-after',
        };
        return {'status': true, 'profile': profileJson(isOnboarded: false)};
      };
      final auth = AuthService(request);

      await auth.fetchLoginUrl();
      final profile = await auth.exchangeTicket('ST-9');

      final exchange = request.calls.last;
      expect(exchange.body, {'ticket': 'ST-9'});
      expect(exchange.headers['X-CSRFToken'], 'token-before');
      expect(exchange.headers['Origin'], kBaseUrl);
      expect(request.headers['X-CSRFToken'], 'token-after');
      expect(request.loggedIn, isTrue);
      expect(profile.isOnboarded, isFalse);
    });

    test('shows the server message when SSO rejects the ticket', () {
      final request = FakeCookieRequest(responders: {
        'POST /akun/api/sso/exchange/': (_) => {
              'status': false,
              'message': 'Pinjemin hanya untuk mahasiswa Universitas Indonesia.',
            },
      });
      expect(
        AuthService(request).exchangeTicket('ST-1'),
        throwsApiException('Pinjemin hanya untuk mahasiswa Universitas Indonesia.'),
      );
    });
  });

  group('restoreSession', () {
    test('returns null without a stored session and makes no request', () async {
      final request = FakeCookieRequest();
      expect(await AuthService(request).restoreSession(), isNull);
      expect(request.calls, isEmpty);
    });

    test('returns the profile when the stored session is still valid', () async {
      mockStoredSession();
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/me/': (_) => {'status': true, 'profile': profileJson(mode: 'seller')},
      });

      final profile = await AuthService(request).restoreSession();

      expect(profile!.isSeller, isTrue);
      expect(request.calls.single.headers['cookie'], contains('sessionid=abc'));
      expect(request.headers['X-CSRFToken'], 'stored-token');
    });

    test('clears the stored session when the server says it expired', () async {
      mockStoredSession();
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/me/': (_) => {'status': false, 'message': 'Sesi kamu sudah habis.'},
      });

      expect(await AuthService(request).restoreSession(), isNull);
      expect(request.loggedIn, isFalse);
      expect(request.cookies, isEmpty);
      expect(request.headers.containsKey('cookie'), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cookies'), '{}');
    });

    test('reports a network failure instead of logging out', () async {
      mockStoredSession();
      final request = FakeCookieRequest(responders: {
        'GET /akun/api/me/': (_) => throw const SocketException('offline'),
      });

      await expectLater(
        AuthService(request).restoreSession(),
        throwsApiException(kNetworkErrorMessage),
      );
      expect(request.cookies, isNotEmpty);
    });
  });
}
