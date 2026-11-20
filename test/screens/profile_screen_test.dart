import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/models/profile.dart';
import 'package:pinjemin_mobile/screens/profile_screen.dart';
import 'package:pinjemin_mobile/services/session_provider.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpTestEnvironment);

  Future<void> pumpProfile(WidgetTester tester, Profile? profile) async {
    final session = SessionProvider();
    if (profile != null) session.setProfile(profile);
    await pumpSettled(
      tester,
      wrapWithApp(const ProfileScreen(), request: FakeCookieRequest(), session: session),
    );
  }

  testWidgets('shows name, NPM, batch and the initial avatar', (tester) async {
    await pumpProfile(tester, sampleProfile());

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Roisul Umam'), findsOneWidget);
    expect(find.text('2506620210 · Angkatan 2025'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('shows completeness with each check', (tester) async {
    await pumpProfile(tester, sampleProfile());

    expect(find.text('Kelengkapan profil'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, 0.75);
    expect(find.text('Foto profil'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(3));
  });

  testWidgets('shows contact info and marks empty fields', (tester) async {
    final json = profileJson()
      ..['phone'] = ''
      ..['bio'] = ' ';
    await pumpProfile(tester, Profile.fromJson(json));

    expect(find.text('Kantin Fasilkom'), findsOneWidget);
    expect(find.text('Belum diisi'), findsNWidgets(2));
  });

  testWidgets('leaves out missing NPM and batch', (tester) async {
    final json = profileJson()
      ..['npm'] = ''
      ..['angkatan'] = null;
    await pumpProfile(tester, Profile.fromJson(json));

    expect(find.textContaining('Angkatan'), findsNothing);
  });

  testWidgets('loads the photo when the profile has one', (tester) async {
    final json = profileJson()..['photo_url'] = 'https://example.test/foto.jpg';
    await pumpProfile(tester, Profile.fromJson(json));

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect((avatar.foregroundImage! as NetworkImage).url, 'https://example.test/foto.jpg');
    // A failed download falls back to the initial without crashing
    avatar.onForegroundImageError!(Exception('offline'), null);
    expect(find.text('R'), findsOneWidget);
  });

  testWidgets('handles a missing profile', (tester) async {
    await pumpProfile(tester, null);

    expect(find.textContaining('Profil belum dimuat'), findsOneWidget);
  });
}
