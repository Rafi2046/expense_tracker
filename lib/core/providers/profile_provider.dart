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

  ProfileProvider({required String initialProfileId})
      : _initialProfileId = initialProfileId {
    _initSync();
    _loadFromDb();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Personal Account');
        syncDefaultProfileName(name);
      }
    });
  }

  void _initSync() {
    _loadProfilesFromPrefs();
    if (_profiles.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      final name = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (user?.email != null && user!.email!.contains('@') ? user.email!.split('@').first : 'Personal Account');
      _profiles.add(UserProfile(id: 'default_profile', name: name, type: 'Personal'));
    }
    _currentProfile = _profiles.first;
  }

  Future<void> _loadFromDb() async {
    try {
      final dbProfiles = await DatabaseHelper.instance.readAllProfiles();
      debugPrint('ProfileProvider._loadFromDb: found ${dbProfiles.length} profiles in DB');
      for (final p in dbProfiles) {
        debugPrint('  -> id=${p['id']} name=${p['name']} type=${p['type']}');
      }

      if (dbProfiles.isEmpty || !dbProfiles.any((p) => p['id'] == 'default_profile')) {
        final name = _profiles.isNotEmpty ? _profiles[0].name : 'Personal';
        await DatabaseHelper.instance.insertProfile({
          'id': 'default_profile',
          'name': name,
          'type': 'Personal',
          'createdAt': DateTime.now().toIso8601String(),
        });
        await _profileDoc('default_profile')?.set({
          'name': name,
          'type': 'Personal',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      final allProfiles = await DatabaseHelper.instance.readAllProfiles();
      debugPrint('ProfileProvider._loadFromDb: DB has ${allProfiles.length} profiles');
      for (final row in allProfiles) {
        final id = row['id'] as String;
        if (!_profiles.any((p) => p.id == id)) {
          _profiles.add(UserProfile(
            id: id,
            name: row['name'] as String,
            type: row['type'] as String,
          ));
          debugPrint('ProfileProvider._loadFromDb: added from DB -> $id');
        }
      }
      if (_profiles.isNotEmpty) {
        final match = _profiles.where((p) => p.id == _initialProfileId);
        _currentProfile = match.isNotEmpty ? match.first : _profiles.first;
        _saveProfilesToPrefs();
      }
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
        _profiles[idx] = UserProfile(id: old.id, name: name, type: old.type);
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
    _profiles[index] = UserProfile(id: old.id, name: newName, type: old.type);

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

  void _saveProfilesToPrefs() {
    final data = _profiles.map((p) => {
      'id': p.id,
      'name': p.name,
      'type': p.type,
    }).toList();
    SharedPrefsHelper.setString('profiles_backup', jsonEncode(data));
  }

  void _loadProfilesFromPrefs() {
    final raw = SharedPrefsHelper.getString('profiles_backup');
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> data = jsonDecode(raw);
      final loaded = data.map((e) => UserProfile(
        id: e['id'] as String,
        name: e['name'] as String,
        type: e['type'] as String,
      )).toList();
      if (loaded.isNotEmpty) {
        _profiles
          ..clear()
          ..addAll(loaded);
        final match = _profiles.where((p) => p.id == _initialProfileId);
        _currentProfile = match.isNotEmpty ? match.first : _profiles.first;
      }
    } catch (_) {}
  }

  Future<UserProfile?> finalizeProfileCreation() async {
    if (_profiles.length >= 3 && !_isPremium) {
      return null;
    }

    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _creationName.trim(),
      type: _creationProfileType == 'business'
          ? 'Business ($_selectedCategory)'
          : 'Personal',
    );

    debugPrint('ProfileProvider.finalizeProfileCreation: saving ${newProfile.name} (${newProfile.id})');

    try {
      await DatabaseHelper.instance.insertProfile({
        'id': newProfile.id,
        'name': newProfile.name,
        'type': newProfile.type,
        'createdAt': DateTime.now().toIso8601String(),
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
    _saveProfilesToPrefs();
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
          id: 'default_profile', name: 'Personal', type: 'Personal',
        ),
      );
      _currentProfile = defaultProfile;
    }

    resetCreationState();
    notifyListeners();
  }
}
