import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final String _initialProfileId;
  final List<UserProfile> _profiles = [];
  late UserProfile _currentProfile;
  bool _isPremium = false;
  bool _isReady = false;
  bool _isCheckingUser = false;

  // Profile Creation Flow State
  String _creationProfileType = 'business'; // 'business' or 'personal'
  String _creationName = '';
  String? _selectedCategory;
  String _categorySearchQuery = '';

  final List<String> _categories = [
    'Agriculture',
    'Auto / Parts',
    'Bakery',
    'Beauty Parlour',
    'Cable Operator',
    'Catering',
    'Clothing',
    'Computer Services',
    'Construction',
    'Consulting',
    'Cosmetics',
    'Dairy Products',
    'Water Jars',
    'Wedding Planning',
    'Education',
    'Electronics',
    'Event Management',
    'Financial Services',
    'Food & Beverage',
    'Furniture',
    'Grocery',
    'Health & Wellness',
    'Home Services',
    'Hospitality',
    'Import/Export',
    'Jewelry',
    'Logistics',
    'Manufacturing',
    'Media & Entertainment',
    'Mobile Services',
    'Pharmacy',
    'Real Estate',
    'Retail',
    'Restaurant',
    'Salon & Spa',
    'Sports & Fitness',
    'Technology',
    'Travel & Tourism',
  ];

  static const String _lastUidKey = 'last_firebase_uid';
  static const String _migrationKey = 'profile_uid_migration_done';

  ProfileProvider({required String initialProfileId})
      : _initialProfileId = initialProfileId {
    _initSync();
    _loadFromDb();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        if (_isReady) {
          _checkUserChanged(user.uid);
        }
        final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Personal Account');
        syncDefaultProfileName(name);
      }
    });
  }

  Future<void> _checkUserChanged(String uid) async {
    if (_isCheckingUser) return;
    _isCheckingUser = true;
    try {
      final migrationDone = SharedPrefsHelper.getBool(_migrationKey) ?? false;

      if (!migrationDone) {
        final allProfiles = await DatabaseHelper.instance.readAllProfiles();
        if (allProfiles.any((p) => p['id'] != 'default_profile')) {
          await _resetProfiles(uid);
        }
        await SharedPrefsHelper.setBool(_migrationKey, true);
      }

      await SharedPrefsHelper.setString(_lastUidKey, uid);
    } finally {
      _isCheckingUser = false;
    }
  }

  Future<void> _resetProfiles(String uid) async {
    debugPrint('ProfileProvider: clearing stale profiles for new user ($uid)');
    final allProfiles = await DatabaseHelper.instance.readAllProfiles();
    for (final p in allProfiles) {
      if (p['id'] != 'default_profile') {
        await DatabaseHelper.instance.deleteProfile(p['id'] as String);
      }
    }
    await SharedPrefsHelper.remove('profiles_backup');
    _profiles.clear();
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (user?.email != null && user!.email!.contains('@') ? user.email!.split('@').first : 'Personal');
    _profiles.add(UserProfile(id: 'default_profile', name: displayName, type: 'Personal', uid: uid));
    _currentProfile = _profiles.first;
    await DatabaseHelper.instance.insertProfile({
      'id': 'default_profile',
      'name': displayName,
      'type': 'Personal',
      'createdAt': DateTime.now().toIso8601String(),
      'uid': uid,
    });
    await _saveProfilesToPrefs();
    notifyListeners();
  }

  void _initSync() {
    _profiles.clear();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _profiles.add(UserProfile(id: 'default_profile', name: 'Personal', type: 'Personal', uid: uid));
    _currentProfile = _profiles.first;
  }

  Future<void> _loadFromDb() async {
    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      currentUser ??= await FirebaseAuth.instance.authStateChanges().first;

      if (currentUser != null) {
        await _checkUserChanged(currentUser.uid);
      }

      _profiles.clear();

      final currentUid = currentUser?.uid;

      final allProfiles = await DatabaseHelper.instance.readAllProfiles();
      debugPrint('ProfileProvider._loadFromDb: DB has ${allProfiles.length} profiles');
      for (final row in allProfiles) {
        final id = row['id'] as String;
        final rowUid = row['uid'] as String?;
        if (rowUid != null && rowUid != currentUid) continue;
        if (rowUid == null && currentUid != null) {
          final db = await DatabaseHelper.instance.database;
          await db.update('profiles', {'uid': currentUid}, where: 'id = ?', whereArgs: [id]);
        }
        _profiles.add(UserProfile(
          id: id,
          name: row['name'] as String,
          type: row['type'] as String,
          uid: currentUid ?? rowUid,
        ));
        debugPrint('ProfileProvider._loadFromDb: added from DB -> $id');
      }

      _profiles.sort((a, b) => a.id == 'default_profile' ? -1 : b.id == 'default_profile' ? 1 : 0);

      if (_profiles.isEmpty) {
        final name = currentUser != null
            ? (currentUser.displayName?.trim().isNotEmpty == true
                ? currentUser.displayName!.trim()
                : (currentUser.email?.contains('@') == true
                    ? currentUser.email!.split('@').first
                    : 'Personal'))
            : 'Personal';
        _profiles.add(UserProfile(id: 'default_profile', name: name, type: 'Personal', uid: currentUid));
        _currentProfile = _profiles.first;
        await DatabaseHelper.instance.insertProfile({
          'id': 'default_profile',
          'name': name,
          'type': 'Personal',
          'createdAt': DateTime.now().toIso8601String(),
          if (currentUid != null) 'uid': currentUid,
        });
        await _profileDoc('default_profile')?.set({
          'name': name,
          'type': 'Personal',
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        final match = _profiles.where((p) => p.id == _initialProfileId);
        _currentProfile = match.isNotEmpty ? match.first : _profiles.first;
      }

      await _saveProfilesToPrefs();
    } catch (e) {
      debugPrint('ProfileProvider._loadFromDb error: $e');
    }
    _isReady = true;
    notifyListeners();
  }

  void syncDefaultProfileName(String name) {
    final idx = _profiles.indexWhere((p) => p.id == 'default_profile');
    if (idx != -1) {
      final old = _profiles[idx];
      if (old.name != name) {
        _profiles[idx] = UserProfile(id: old.id, name: name, type: old.type, uid: old.uid);
        DatabaseHelper.instance.updateProfile('default_profile', {'name': name});
        _profileDoc('default_profile')?.set({'name': name}, SetOptions(merge: true));
        if (_currentProfile.id == 'default_profile') {
          _currentProfile = _profiles[idx];
        }
        notifyListeners();
      }
    }
  }

  DocumentReference? _profileDoc(String profileId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(profileId);
  }

  Future<void> reload() async {
    await _loadFromDb();
  }

  // Getters
  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  UserProfile get currentProfile => _currentProfile;
  bool get isPremium => _isPremium;
  bool get isReady => _isReady;

  String get creationProfileType => _creationProfileType;
  String get creationName => _creationName;
  String? get selectedCategory => _selectedCategory;
  String get categorySearchQuery => _categorySearchQuery;
  List<String> get categories => _categories;

  List<String> get filteredCategories {
    if (_categorySearchQuery.isEmpty) {
      return _categories;
    }
    return _categories
        .where((c) => c.toLowerCase().contains(_categorySearchQuery.toLowerCase()))
        .toList();
  }

  set isPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // Setters & Actions
  void addProfile(UserProfile profile) {
    _profiles.add(profile);
    _currentProfile = profile;
    _saveProfilesToPrefs();
    notifyListeners();
  }

  void selectProfile(UserProfile profile) {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _currentProfile = _profiles[index];
    } else {
      _currentProfile = profile;
    }
    notifyListeners();
  }

  Future<void> updateProfileName(String profileId, String newName) async {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return;

    final old = _profiles[index];
    _profiles[index] = UserProfile(id: old.id, name: newName, type: old.type, uid: old.uid);

    if (_currentProfile.id == profileId) {
      _currentProfile = _profiles[index];
    }

    await DatabaseHelper.instance.updateProfile(profileId, {'name': newName});
    await _profileDoc(profileId)?.set({'name': newName}, SetOptions(merge: true));
    notifyListeners();
  }

  void setCreationProfileType(String type) {
    _creationProfileType = type;
    notifyListeners();
  }

  void setCreationName(String name) {
    _creationName = name;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCategorySearchQuery(String query) {
    _categorySearchQuery = query;
    notifyListeners();
  }

  void resetCreationState() {
    _creationProfileType = 'business';
    _creationName = '';
    _selectedCategory = null;
    _categorySearchQuery = '';
    notifyListeners();
  }

  Future<void> _saveProfilesToPrefs() async {
    final data = _profiles.map((p) => {
      'id': p.id,
      'name': p.name,
      'type': p.type,
      if (p.uid != null) 'uid': p.uid,
    }).toList();
    await SharedPrefsHelper.setString('profiles_backup', jsonEncode(data));
  }

  Future<UserProfile?> finalizeProfileCreation() async {
    if (_profiles.length >= 3 && !_isPremium) {
      return null;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _creationName.trim(),
      type: _creationProfileType == 'business'
          ? 'Business ($_selectedCategory)'
          : 'Personal',
      uid: currentUid,
    );

    debugPrint('ProfileProvider.finalizeProfileCreation: saving ${newProfile.name} (${newProfile.id})');

    try {
      await DatabaseHelper.instance.insertProfile({
        'id': newProfile.id,
        'name': newProfile.name,
        'type': newProfile.type,
        'createdAt': DateTime.now().toIso8601String(),
        if (currentUid != null) 'uid': currentUid,
      });

      final verify = await DatabaseHelper.instance.readAllProfiles();
      debugPrint('ProfileProvider.finalizeProfileCreation: DB now has ${verify.length} profiles');
      for (final v in verify) {
        debugPrint('  -> DB: id=${v['id']} name=${v['name']}');
      }

      try {
        await _profileDoc(newProfile.id)?.set({
          'name': newProfile.name,
          'type': newProfile.type,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('ProfileProvider.finalizeProfileCreation: Firestore backup failed: $e');
      }
    } catch (e) {
      debugPrint('ProfileProvider.finalizeProfileCreation: DB insert FAILED: $e');
      return null;
    }

    _profiles.add(newProfile);
    _currentProfile = newProfile;
    await _saveProfilesToPrefs();
    resetCreationState();
    notifyListeners();
    return newProfile;
  }

  /// Deletes a profile and all its associated data. The default profile
  /// cannot be deleted. If the deleted profile was the active one, the
  /// app auto-switches to the default profile.
  Future<void> deleteProfile(String profileId) async {
    if (profileId == 'default_profile') return;

    await DatabaseHelper.instance.deleteProfileAndData(profileId);
    await _profileDoc(profileId)?.delete();

    _profiles.removeWhere((p) => p.id == profileId);

    if (_currentProfile.id == profileId) {
      final defaultProfile = _profiles.firstWhere(
        (p) => p.id == 'default_profile',
        orElse: () => _profiles.isNotEmpty ? _profiles.first : UserProfile(
          id: 'default_profile', name: 'Personal', type: 'Personal', uid: FirebaseAuth.instance.currentUser?.uid,
        ),
      );
      _currentProfile = defaultProfile;
    }

    resetCreationState();
    notifyListeners();
  }
}
