import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:expense_tracker/core/constants/app_strings.dart';
import 'package:expense_tracker/core/utils/profile_photo_resolver.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/tours/utils/tour_image_codec.dart';

class SessionProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  String? _cloudPhotoUrl;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _photoSub;

  SessionProvider() {
    _authSub = _auth.userChanges().listen(_onUserChanged);
    final current = _auth.currentUser;
    if (current != null) {
      _firebaseUser = current;
      _attachPhotoListener(current.uid);
    }
  }

  void _onUserChanged(User? user) {
    final previousUid = _firebaseUser?.uid;
    _firebaseUser = user;
    if (user == null) {
      _photoSub?.cancel();
      _photoSub = null;
      _cloudPhotoUrl = null;
    } else if (user.uid != previousUid) {
      _attachPhotoListener(user.uid);
    }
    notifyListeners();
  }

  void _attachPhotoListener(String uid) {
    _photoSub?.cancel();
    _photoSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('profile')
        .snapshots()
        .listen(
      (snap) {
        final remote = snap.data()?['photoUrl'] as String?;
        final normalized =
            ProfilePhotoResolver.isCloudValue(remote) ? remote : null;
        if (normalized != _cloudPhotoUrl) {
          _cloudPhotoUrl = normalized;
          if (normalized != null) {
            SharedPrefsHelper.setString(
              '${AppStrings.sessionLocalPhotoPrefix}$uid',
              normalized,
            );
          }
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint('SessionProvider photo listener error: $e');
      },
    );
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
      final fc = word.isNotEmpty ? String.fromCharCode(word.runes.first) : '';
      return '${fc.toUpperCase()}${word.substring(1).toLowerCase()}';
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

  /// Cross-device: Firestore cloud value (https or b64) wins.
  /// Local file is for this-device saves when cloud upload has not landed yet.
  String? get photoUrl {
    final user = _firebaseUser;
    if (user == null) return null;

    if (ProfilePhotoResolver.isCloudValue(_cloudPhotoUrl)) {
      return _cloudPhotoUrl;
    }

    final local = SharedPrefsHelper.getString(
      '${AppStrings.sessionLocalPhotoPrefix}${user.uid}',
    );
    if (local != null &&
        local.isNotEmpty &&
        !TourImageCodec.isNetwork(local) &&
        !TourImageCodec.isBase64(local) &&
        File(local).existsSync()) {
      return local;
    }

    final authUrl = user.photoURL;
    if (TourImageCodec.isNetwork(authUrl)) return authUrl;

    if (ProfilePhotoResolver.isCloudValue(local)) return local;

    return null;
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
      return parts[0].runes.isNotEmpty
          ? String.fromCharCode(parts[0].runes.first).toUpperCase()
          : '';
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) {
      return String.fromCharCode(email.runes.first).toUpperCase();
    }

    return '?';
  }

  Future<void> refresh() async {
    await _auth.currentUser?.reload();
    _firebaseUser = _auth.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _photoSub?.cancel();
    super.dispose();
  }
}
