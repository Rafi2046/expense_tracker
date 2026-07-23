import 'package:flutter/material.dart';
import '../utils/shared_prefs_helper.dart';

class ProfileManagerProvider extends ChangeNotifier {
  String _activeProfileId;

  ProfileManagerProvider({required String initialProfileId})
      : _activeProfileId = initialProfileId {
    debugPrint('ProfileManagerProvider: init with $_activeProfileId');
  }

  String get activeProfileId => _activeProfileId;

  Future<void> switchProfile(String newProfileId) async {
    debugPrint('ProfileManagerProvider: switchProfile from $_activeProfileId to $newProfileId');
    if (newProfileId == _activeProfileId) {
      // Still reinforce prefs in case UI already wrote a different value.
      await SharedPrefsHelper.setString(
        SharedPrefsHelper.activeProfileKey,
        newProfileId,
      );
      return;
    }
    _activeProfileId = newProfileId;
    await SharedPrefsHelper.setString(
      SharedPrefsHelper.activeProfileKey,
      newProfileId,
    );
    notifyListeners();
  }
}
