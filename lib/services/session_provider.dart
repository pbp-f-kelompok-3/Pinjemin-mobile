import 'package:flutter/foundation.dart';

import '../models/profile.dart';

/// Local copy of the logged-in profile. The server stays the source of truth:
/// this is filled after login or session restore and replaced after each update.
class SessionProvider extends ChangeNotifier {
  Profile? _profile;

  Profile? get profile => _profile;

  bool get isLoggedIn => _profile != null;

  bool get isSeller => _profile?.isSeller ?? false;

  String get modeLabel => _profile?.modeLabel ?? 'Minjem';

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
