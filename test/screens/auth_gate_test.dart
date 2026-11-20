import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/main.dart';
import 'package:pinjemin_mobile/screens/home_screen.dart';
import 'package:pinjemin_mobile/screens/login_screen.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpTestEnvironment);

  testWidgets('shows a spinner, then the login screen without a session', (tester) async {
    mockStoredSession(loggedIn: false);
    await tester.pumpWidget(PinjeminApp(request: FakeCookieRequest()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('opens the home screen when the stored session is valid', (tester) async {
    mockStoredSession();
    final request = FakeCookieRequest(responders: {
      'GET /akun/api/me/': (_) => {'status': true, 'profile': profileJson(mode: 'seller')},
    });

    await pumpSettled(tester, PinjeminApp(request: request));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Halo, Roisul'), findsOneWidget);
    expect(find.text('Minjemin'), findsOneWidget);
  });

  testWidgets('offers a retry when the server cannot be reached', (tester) async {
    mockStoredSession();
    var attempts = 0;
    final request = FakeCookieRequest(responders: {
      'GET /akun/api/me/': (_) {
        attempts++;
        if (attempts == 1) throw const SocketException('offline');
        return {'status': true, 'profile': profileJson()};
      },
    });

    await pumpSettled(tester, PinjeminApp(request: request));
    expect(find.textContaining('Tidak bisa terhubung ke server'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('falls back to the generic message for unexpected errors', (tester) async {
    mockStoredSession();
    final request = FakeCookieRequest(responders: {
      'GET /akun/api/me/': (_) => throw StateError('bug'),
    });

    await pumpSettled(tester, PinjeminApp(request: request));
    expect(find.textContaining('Tidak bisa terhubung ke server'), findsOneWidget);
  });

  testWidgets('theme follows the Pinjemin palette', (tester) async {
    final theme = PinjeminTheme.build();
    final colors = theme.extension<PinjeminColors>()!;

    expect(theme.colorScheme.primary, const Color(0xFFFFE100));
    expect(theme.colorScheme.onPrimary, const Color(0xFF1C1C1C));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF8F6F7));
    expect(theme.colorScheme.error, const Color(0xFFC4161C));
    expect(theme.appBarTheme.scrolledUnderElevation, 0);
    expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
    expect(theme.textTheme.headlineMedium!.fontWeight, FontWeight.w800);
    expect(theme.textTheme.bodyLarge!.height, 1.5);
    expect(theme.textTheme.bodyLarge!.fontFamily, contains('PlusJakartaSans'));
    expect(colors.copyWith(), same(colors));
    expect(colors.lerp(null, 0.5), same(colors));

    final fill = theme.inputDecorationTheme.fillColor as WidgetStateColor;
    expect(fill.resolve({WidgetState.focused}), Colors.white);
    expect(fill.resolve({}), colors.fieldFill);
  });
}
