import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:expense_tracker/core/constants/app_strings.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class SessionProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _firebaseUser;

  SessionProvider() {
    _auth.userChanges().listen(_onUserChanged);
  }

  void _onUserChanged(User? user) {
    _firebaseUser = user;
    notifyListeners();
  }

  User? get firebaseUser => _firebaseUser;
  bool get isLoggedIn => _firebaseUser != null;

  String get displayName {
    final user = _firebaseUser;
    if (user == null) return '';

    final explicit = user.displayName;
    if (explicit != null && explicit.trim().isNotEmpty) return explicit;

    final emailPrefix = _parseEmailPrefix(user.email);
    if (emailPrefix != null) return emailPrefix;

    return AppStrings.defaultUserName;
  }

  String get firstName {
    final full = displayName.trim();
    if (full.isEmpty) return full;

    final parts = full.split(' ');
    if (parts.length <= 2) return _toTitleCase(full);

    return _toTitleCase('${parts[0]} ${parts[1]}');
  }

  String _toTitleCase(String value) {
    if (value.isEmpty) return value;
    return value.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  String? _parseEmailPrefix(String? email) {
    if (email == null) return null;
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) return null;
    final prefix = email.substring(0, atIndex);
    if (prefix.isEmpty) return null;
    return prefix.replaceAll('.', ' ').replaceAll('_', ' ');
  }

  String? get photoUrl {
    final user = _firebaseUser;
    if (user == null) return null;

    final localPath = SharedPrefsHelper.getString(
      '${AppStrings.sessionLocalPhotoPrefix}${user.uid}',
    );
    if (localPath != null && localPath.isNotEmpty) return localPath;

    return user.photoURL;
  }

  String get initials {
    final user = _firebaseUser;
    if (user == null) return '?';

    final explicit = user.displayName;
    if (explicit != null && explicit.trim().isNotEmpty) {
      final parts = explicit.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();

    return '?';
  }

  Future<void> refresh() async {
    await _auth.currentUser?.reload();
    _firebaseUser = _auth.currentUser;
    notifyListeners();
  }
}
