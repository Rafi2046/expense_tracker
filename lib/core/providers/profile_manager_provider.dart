import 'package:flutter/material.dart';
import '../utils/shared_prefs_helper.dart';

class ProfileManagerProvider extends ChangeNotifier {
  static const String _activeProfileIdKey = 'active_profile_id';

  String _activeProfileId;

  ProfileManagerProvider() : _activeProfileId = 'default_profile' {
    _loadActiveProfile();
  }

  String get activeProfileId => _activeProfileId;

  void _loadActiveProfile() {
    _activeProfileId =
        SharedPrefsHelper.getString(_activeProfileIdKey) ?? 'default_profile';
  }

  void switchProfile(String newProfileId) {
    if (newProfileId == _activeProfileId) return;
    _activeProfileId = newProfileId;
    SharedPrefsHelper.setString(_activeProfileIdKey, newProfileId);
    notifyListeners();
  }
}
