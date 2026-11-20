// Generated with quicktype from the /akun/api/me/ response, then trimmed by hand.
import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  Profile({
    required this.id,
    required this.username,
    required this.npm,
    required this.fullName,
    required this.kodeOrg,
    required this.angkatan,
    required this.phone,
    required this.bio,
    required this.location,
    required this.photoUrl,
    required this.mode,
    required this.modeLabel,
    required this.isSeller,
    required this.isOnboarded,
    required this.completeness,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String npm;
  final String fullName;
  final String kodeOrg;
  final int? angkatan;
  final String phone;
  final String bio;
  final String location;
  final String? photoUrl;
  final String mode;
  final String modeLabel;
  final bool isSeller;
  final bool isOnboarded;
  final Completeness completeness;
  final DateTime createdAt;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        username: json['username'],
        npm: json['npm'],
        fullName: json['full_name'],
        kodeOrg: json['kode_org'],
        angkatan: json['angkatan'],
        phone: json['phone'],
        bio: json['bio'],
        location: json['location'],
        photoUrl: json['photo_url'],
        mode: json['mode'],
        modeLabel: json['mode_label'],
        isSeller: json['is_seller'],
        isOnboarded: json['is_onboarded'],
        completeness: Completeness.fromJson(json['completeness']),
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'npm': npm,
        'full_name': fullName,
        'kode_org': kodeOrg,
        'angkatan': angkatan,
        'phone': phone,
        'bio': bio,
        'location': location,
        'photo_url': photoUrl,
        'mode': mode,
        'mode_label': modeLabel,
        'is_seller': isSeller,
        'is_onboarded': isOnboarded,
        'completeness': completeness.toJson(),
        'created_at': createdAt.toIso8601String(),
      };

  /// Name shown in the UI; SSO accounts always have a username, not always a full name.
  String get displayName => fullName.trim().isEmpty ? username : fullName.trim();

  String get firstName => displayName.split(RegExp(r'\s+')).first;
}

class Completeness {
  Completeness({required this.percent, required this.checks});

  final int percent;
  final List<CompletenessCheck> checks;

  factory Completeness.fromJson(Map<String, dynamic> json) => Completeness(
        percent: json['percent'],
        checks: List<CompletenessCheck>.from(
          (json['checks'] as List).map((x) => CompletenessCheck.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        'percent': percent,
        'checks': checks.map((x) => x.toJson()).toList(),
      };
}

class CompletenessCheck {
  CompletenessCheck({required this.label, required this.done});

  final String label;
  final bool done;

  factory CompletenessCheck.fromJson(Map<String, dynamic> json) =>
      CompletenessCheck(label: json['label'], done: json['done']);

  Map<String, dynamic> toJson() => {'label': label, 'done': done};
}
