import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pinjemin_mobile/models/profile.dart';

import '../helpers/fakes.dart';

void main() {
  group('Profile', () {
    test('fromJson reads every field', () {
      final profile = Profile.fromJson(profileJson(mode: 'seller'));

      expect(profile.id, 7);
      expect(profile.username, 'roisul.umam');
      expect(profile.npm, '2506620210');
      expect(profile.kodeOrg, '01.00.12.01');
      expect(profile.angkatan, 2025);
      expect(profile.photoUrl, isNull);
      expect(profile.mode, 'seller');
      expect(profile.modeLabel, 'Minjemin');
      expect(profile.isSeller, isTrue);
      expect(profile.isOnboarded, isTrue);
      expect(profile.completeness.percent, 75);
      expect(profile.completeness.checks, hasLength(4));
      expect(profile.completeness.checks.first.label, 'Foto profil');
      expect(profile.completeness.checks.first.done, isFalse);
      expect(profile.createdAt.toUtc(), DateTime.utc(2026, 11, 1, 1));
    });

    test('toJson and fromJson round trip', () {
      final source = jsonEncode(profileJson());
      final profile = profileFromJson(source);
      final again = profileFromJson(profileToJson(profile));

      expect(again.toJson(), profile.toJson());
      expect(again.completeness.checks[1].toJson(), {
        'label': 'Nomor WhatsApp',
        'done': true,
      });
    });

    test('displayName and firstName use the full name', () {
      final profile = sampleProfile(fullName: '  Roisul   Umam ');
      expect(profile.displayName, 'Roisul   Umam');
      expect(profile.firstName, 'Roisul');
    });

    test('displayName falls back to the username', () {
      final profile = sampleProfile(fullName: '');
      expect(profile.displayName, 'roisul.umam');
      expect(profile.firstName, 'roisul.umam');
    });
  });
}
