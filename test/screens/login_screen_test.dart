import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/screens/login_screen.dart';
import 'package:pinjemin_mobile/services/session_provider.dart';
import 'package:pinjemin_mobile/widgets/soft_blobs.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpTestEnvironment);
  setUp(() => mockStoredSession(loggedIn: false));

  FakeCookieRequest serverWith({FakeResponder? exchange}) {
    return FakeCookieRequest(responders: {
      'GET /akun/api/sso/start/': (_) => {
            'status': true,
            'login_url': 'https://sso.ui.ac.id/cas2/login?service=x',
          },
      'POST /akun/api/sso/exchange/':
          exchange ?? (_) => {'status': true, 'profile': profileJson()},
    });
  }

  testWidgets('shows the logo, title and SSO button', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(const LoginScreen(), request: FakeCookieRequest()),
    );

    expect(find.byType(SoftBlobs), findsOneWidget);
    expect(find.bySemanticsLabel('Pinjemin'), findsOneWidget);
    expect(find.text('Masuk ke Pinjemin'), findsOneWidget);
    expect(find.text('Masuk dengan SSO UI'), findsOneWidget);
    expect(find.textContaining('Khusus mahasiswa Universitas Indonesia'), findsOneWidget);
  });

  testWidgets('successful SSO login fills the session', (tester) async {
    final session = SessionProvider();
    final request = serverWith();
    String? openedUrl;
    String? openedPrefix;

    await pumpSettled(
      tester,
      wrapWithApp(
        LoginScreen(
          launchSso: (context, url, prefix) async {
            openedUrl = url;
            openedPrefix = prefix;
            return 'ST-42';
          },
        ),
        request: request,
        session: session,
      ),
    );
    await tester.tap(find.text('Masuk dengan SSO UI'));
    await tester.pumpAndSettle();

    expect(openedUrl, 'https://sso.ui.ac.id/cas2/login?service=x');
    expect(openedPrefix, api('/akun/api/sso/callback/'));
    expect(request.calls.last.body, {'ticket': 'ST-42'});
    expect(session.profile!.firstName, 'Roisul');
  });

  testWidgets('closing the SSO page leaves the user on the login screen', (tester) async {
    final session = SessionProvider();
    final request = serverWith();

    await pumpSettled(
      tester,
      wrapWithApp(
        LoginScreen(launchSso: (context, url, prefix) async => null),
        request: request,
        session: session,
      ),
    );
    await tester.tap(find.text('Masuk dengan SSO UI'));
    await tester.pumpAndSettle();

    expect(session.isLoggedIn, isFalse);
    expect(request.calls, hasLength(1));
    expect(find.text('Masuk dengan SSO UI'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('shows the server message when the account is rejected', (tester) async {
    final request = serverWith(
      exchange: (_) => {
        'status': false,
        'message': 'Pinjemin hanya untuk mahasiswa Universitas Indonesia.',
      },
    );

    await pumpSettled(
      tester,
      wrapWithApp(
        LoginScreen(launchSso: (context, url, prefix) async => 'ST-1'),
        request: request,
      ),
    );
    await tester.tap(find.text('Masuk dengan SSO UI'));
    await tester.pumpAndSettle();

    expect(find.text('Pinjemin hanya untuk mahasiswa Universitas Indonesia.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('shows a loading state while the SSO page is open', (tester) async {
    final ssoPage = Completer<String?>();

    await pumpSettled(
      tester,
      wrapWithApp(
        LoginScreen(launchSso: (context, url, prefix) => ssoPage.future),
        request: serverWith(),
      ),
    );
    await tester.tap(find.text('Masuk dengan SSO UI'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Menghubungkan...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    ssoPage.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Masuk dengan SSO UI'), findsOneWidget);
  });

  testWidgets('shows a friendly message when the server is unreachable', (tester) async {
    final request = FakeCookieRequest(responders: {
      'GET /akun/api/sso/start/': (_) => throw const SocketException('offline'),
    });

    await pumpSettled(
      tester,
      wrapWithApp(
        LoginScreen(launchSso: (context, url, prefix) async => 'ST-1'),
        request: request,
      ),
    );
    await tester.tap(find.text('Masuk dengan SSO UI'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tidak bisa terhubung ke server'), findsOneWidget);
    expect(find.text('Masuk dengan SSO UI'), findsOneWidget);
  });
}
