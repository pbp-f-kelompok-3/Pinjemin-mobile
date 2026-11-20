import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/models/help_content.dart';
import 'package:pinjemin_mobile/screens/help_center_screen.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpTestEnvironment);

  // The list inside the visible tab (TabBarView only builds the current page)
  Finder tabList() =>
      find.descendant(of: find.byType(TabBarView), matching: find.byType(Scrollable)).last;

  Future<void> pumpHelp(WidgetTester tester) => pumpSettled(
        tester,
        wrapWithApp(const HelpCenterScreen(), request: FakeCookieRequest()),
      );

  testWidgets('opens on the tutorial with both modes', (tester) async {
    await pumpHelp(tester);

    expect(find.text('Bantuan'), findsOneWidget);
    expect(find.text('Tutorial'), findsOneWidget);
    expect(find.text('Cara meminjam barang'), findsOneWidget);
    expect(find.text(borrowSteps.first.title), findsOneWidget);

    await tester.scrollUntilVisible(find.text(lendSteps.last.title), 200, scrollable: tabList());
    expect(find.text('Cara meminjamkan barang'), findsOneWidget);
  });

  testWidgets('privacy tab lists every policy section', (tester) async {
    await pumpHelp(tester);

    await tester.tap(find.text('Privasi'));
    await tester.pumpAndSettle();

    expect(find.text('Kebijakan privasi'), findsOneWidget);
    expect(find.text(policyUpdatedAt), findsOneWidget);
    for (var i = 0; i < policySections.length; i++) {
      final title = '${i + 1}. ${policySections[i].title}';
      await tester.scrollUntilVisible(find.text(title), 200, scrollable: tabList());
      expect(find.text(title), findsOneWidget);
    }
  });

  testWidgets('FAQ answers open on tap', (tester) async {
    await pumpHelp(tester);

    await tester.tap(find.text('FAQ'));
    await tester.pumpAndSettle();

    final first = faqItems.first;
    expect(find.text(first.question), findsOneWidget);
    expect(find.text(first.answer), findsNothing);

    await tester.tap(find.text(first.question));
    await tester.pumpAndSettle();
    expect(find.text(first.answer), findsOneWidget);
  });

  testWidgets('tab labels are dark text, never yellow', (tester) async {
    await pumpHelp(tester);

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    final theme = Theme.of(tester.element(find.byType(TabBar)));
    expect(tabBar.labelColor, theme.colorScheme.onSurface);
    expect(tabBar.indicatorColor, theme.colorScheme.primary);
  });
}
