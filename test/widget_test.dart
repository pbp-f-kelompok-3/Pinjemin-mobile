import 'package:flutter_test/flutter_test.dart';

import 'package:pinjemin_mobile/main.dart';

void main() {
  testWidgets('Pinjemin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Pinjemin'), findsWidgets);
  });
}
