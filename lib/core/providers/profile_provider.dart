import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final List<UserProfile> _profiles = [
    UserProfile(id: '1', name: 'Rafi', type: 'Personal'),
    UserProfile(id: '2', name: 'Office', type: 'Business'),
  ];

  late UserProfile _currentProfile;

  ProfileProvider() {
    _currentProfile = _profiles.first;
  }

  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  UserProfile get currentProfile => _currentProfile;

  void addProfile(UserProfile profile) {
    _profiles.add(profile);
    _currentProfile = profile;
    notifyListeners();
  }

  void selectProfile(UserProfile profile) {
    if (_profiles.contains(profile)) {
      _currentProfile = profile;
      notifyListeners();
    }
  }
}
