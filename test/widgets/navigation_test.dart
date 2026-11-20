import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/screens/help_center_screen.dart';
import 'package:pinjemin_mobile/screens/home_screen.dart';
import 'package:pinjemin_mobile/screens/profile_screen.dart';
import 'package:pinjemin_mobile/services/session_provider.dart';
import 'package:pinjemin_mobile/widgets/pinjemin_app_bar.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpTestEnvironment);

  SessionProvider sessionWith({String mode = 'renter', String fullName = 'Roisul Umam'}) =>
      SessionProvider()..setProfile(sampleProfile(mode: mode, fullName: fullName));

  testWidgets('home greets the user and shows the active mode', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(const HomeScreen(), request: FakeCookieRequest(), session: sessionWith()),
    );

    expect(find.text('Halo, Roisul'), findsOneWidget);
    expect(find.text('Kamu sedang di mode Minjem.'), findsOneWidget);
    expect(find.bySemanticsLabel('Mode aktif: Minjem'), findsOneWidget);
  });

  testWidgets('mode chip follows the provider', (tester) async {
    final session = sessionWith();
    await pumpSettled(
      tester,
      wrapWithApp(const HomeScreen(), request: FakeCookieRequest(), session: session),
    );

    session.setProfile(sampleProfile(mode: 'seller'));
    await tester.pumpAndSettle();

    expect(find.text('Minjemin'), findsOneWidget);
    expect(find.text('Kamu sedang di mode Minjemin.'), findsOneWidget);
  });

  testWidgets('app bar can show a page title instead of the logo', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(
        const Scaffold(appBar: PinjeminAppBar(title: 'Profil')),
        request: FakeCookieRequest(),
        session: sessionWith(),
      ),
    );

    expect(find.text('Profil'), findsOneWidget);
    expect(find.bySemanticsLabel('Pinjemin'), findsNothing);
  });

  testWidgets('drawer shows the user and goes back to the home screen', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(const HomeScreen(), request: FakeCookieRequest(), session: sessionWith()),
    );

    // Push a second page, then use the drawer on the home screen below it
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute(builder: (_) => const HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Roisul Umam'), findsOneWidget);
    expect(find.text('2506620210'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);

    await tester.tap(find.text('Beranda'));
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isFalse);
    expect(find.text('Beranda'), findsNothing);
  });

  Future<void> openDrawerItem(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Open navigation menu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('drawer opens Profil and Bantuan without stacking pages', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(const HomeScreen(), request: FakeCookieRequest(), session: sessionWith()),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    await openDrawerItem(tester, 'Profil');
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);

    await openDrawerItem(tester, 'Bantuan');
    expect(find.byType(HelpCenterScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);

    // Back goes straight to home, not to the profile page
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Halo, Roisul'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('Beranda in the drawer closes it on the home screen', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(const HomeScreen(), request: FakeCookieRequest(), session: sessionWith()),
    );

    await openDrawerItem(tester, 'Beranda');
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Halo, Roisul'), findsOneWidget);
  });

  testWidgets('drawer handles a missing profile', (tester) async {
    await pumpSettled(
      tester,
      wrapWithApp(const HomeScreen(), request: FakeCookieRequest()),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Pinjemin'), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
  });
}
