import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/services/session_provider.dart';

import '../helpers/fakes.dart';

void main() {
  test('starts logged out in Minjem mode', () {
    final session = SessionProvider();
    expect(session.isLoggedIn, isFalse);
    expect(session.profile, isNull);
    expect(session.isSeller, isFalse);
    expect(session.modeLabel, 'Minjem');
  });

  test('setProfile and clear notify listeners', () {
    final session = SessionProvider();
    var notified = 0;
    session.addListener(() => notified++);

    session.setProfile(sampleProfile(mode: 'seller'));
    expect(session.isLoggedIn, isTrue);
    expect(session.isSeller, isTrue);
    expect(session.modeLabel, 'Minjemin');

    session.clear();
    expect(session.isLoggedIn, isFalse);
    expect(notified, 2);
  });
}
