import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final String _initialProfileId;
  final List<UserProfile> _profiles = [];
  final Set<String> _knownProfileIds = {};
  late UserProfile _currentProfile;
  bool _isPremium = false;
  bool _isReady = false;
  String? _lastLoadedUid;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _profileSubscription;
  Future<void>? _loadingFuture;
  Future<void> _onAuthChangedChain = Future.value();

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
    _loadingFuture = _loadFromDb();
    _authSubscription = FirebaseAuth.instance.userChanges().listen(_onAuthChanged);
  }

  void _initSync() {
    _profiles.clear();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _profiles.add(UserProfile(id: 'default_profile', name: 'Personal', type: 'Personal', uid: uid));
    // Honour the cold-start id immediately so a late DB load / auth reload
    // cannot briefly treat "default_profile" as selected when prefs say otherwise.
    if (_initialProfileId != 'default_profile') {
      _profiles.add(UserProfile(
        id: _initialProfileId,
        name: 'Profile',
        type: 'Secondary',
        uid: uid,
      ));
      _currentProfile = _profiles.last;
    } else {
      _currentProfile = _profiles.first;
    }
  }

  void _onAuthChanged(User? newUser) {
    _onAuthChangedChain = _onAuthChangedChain.then((_) async {
      await _handleAuthChanged(newUser);
    });
  }

  Future<void> _handleAuthChanged(User? newUser) async {
    if (_loadingFuture != null) {
      await _loadingFuture;
    }

    final uidChanged = newUser?.uid != _lastLoadedUid;

    _profileSubscription?.cancel();
    _profileSubscription = null;
    _knownProfileIds.clear();

    if (newUser == null) {
      _initSync();
      _isReady = false;
      notifyListeners();
      return;
    }

    if (uidChanged) {
      _profiles.clear();
      _loadingFuture = _loadFromDb(force: true);
      await _loadingFuture;
    }

    _attachProfileListener(newUser.uid);
  }

  void _attachProfileListener(String uid) {
    _profileSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .snapshots()
        .listen(
          (snapshot) {
            bool changed = false;
            for (final change in snapshot.docChanges) {
              final docId = change.doc.id;
              final data = change.doc.data();
              if (data == null) continue;
              switch (change.type) {
                case DocumentChangeType.added:
                  if (!_knownProfileIds.contains(docId) && !_profiles.any((p) => p.id == docId)) {
                    _knownProfileIds.add(docId);
                    DatabaseHelper.instance.insertProfile({
                      'id': docId,
                      'name': data['name'] ?? 'Personal',
                      'type': data['type'] ?? 'Personal',
                      'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
                      'uid': uid,
                    });
                    _profiles.add(UserProfile(
                      id: docId,
                      name: data['name'] ?? 'Personal',
                      type: data['type'] ?? 'Personal',
                      uid: uid,
                    ));
                    changed = true;
                  }
                  break;
                case DocumentChangeType.modified:
                  _knownProfileIds.add(docId);
                  DatabaseHelper.instance.updateProfile(docId, {
                    'name': data['name'] ?? 'Personal',
                    'type': data['type'] ?? 'Personal',
                  });
                  final idx = _profiles.indexWhere((p) => p.id == docId);
                  if (idx != -1) {
                    _profiles[idx] = UserProfile(
                      id: docId,
                      name: data['name'] ?? 'Personal',
                      type: data['type'] ?? 'Personal',
                      uid: uid,
                    );
                  } else {
                    _profiles.add(UserProfile(
                      id: docId,
                      name: data['name'] ?? 'Personal',
                      type: data['type'] ?? 'Personal',
                      uid: uid,
                    ));
                  }
                  changed = true;
                  break;
                case DocumentChangeType.removed:
                  _knownProfileIds.remove(docId);
                  DatabaseHelper.instance.deleteProfileAndData(docId);
                  _profiles.removeWhere((p) => p.id == docId);
                  if (_currentProfile.id == docId) {
                    final defaultProfile = _profiles.firstWhere(
                      (p) => p.id == 'default_profile',
                      orElse: () => _profiles.isNotEmpty ? _profiles.first : UserProfile(
                        id: 'default_profile', name: 'Personal', type: 'Personal', uid: uid,
                      ),
                    );
                    _currentProfile = defaultProfile;
                    SharedPrefsHelper.setString(
                      SharedPrefsHelper.activeProfileKey,
                      defaultProfile.id,
                    );
                  }
                  changed = true;
                  break;
              }
            }
            if (changed) {
              _profiles.sort((a, b) => a.id == 'default_profile' ? -1 : b.id == 'default_profile' ? 1 : 0);
              _saveProfilesToPrefs();
              _isReady = true;
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('ProfileProvider: Firestore snapshot listener error: $error');
          },
        );
  }

  Future<void> _loadFromDb({bool force = false}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUid = currentUser?.uid;

      if (!force && _isReady && currentUid == _lastLoadedUid) {
        return;
      }
      _lastLoadedUid = currentUid;

      // SharedPrefs is always the source of truth for which profile to restore.
      // Never prefer in-memory `_currentProfile` on force reload — that used to
      // overwrite prefs with a transient secondary selection after auth/sync.
      final savedId = SharedPrefsHelper.getString(SharedPrefsHelper.activeProfileKey);
      final preservedProfileId = savedId ?? _initialProfileId;

      _profiles.clear();
      _knownProfileIds.clear();
      final Set<String> seenIds = {};

      final dbProfiles = await DatabaseHelper.instance.readAllProfiles();
      final allProfiles = List<Map<String, dynamic>>.from(dbProfiles);
      allProfiles.sort((a, b) {
        if (a['id'] == 'default_profile') return -1;
        if (b['id'] == 'default_profile') return 1;
        final ca = a['createdAt'] as String? ?? '';
        final cb = b['createdAt'] as String? ?? '';
        return ca.compareTo(cb);
      });

      debugPrint('ProfileProvider._loadFromDb: DB has ${allProfiles.length} profiles');
      for (final row in allProfiles) {
        final id = row['id'] as String;
        if (!seenIds.add(id)) {
          final db = await DatabaseHelper.instance.database;
          await db.delete('profiles', where: 'id = ? AND rowid != (SELECT MIN(rowid) FROM profiles WHERE id = ?)', whereArgs: [id, id]);
          continue;
        }
        var rowUid = row['uid'] as String?;
        debugPrint('ProfileProvider._loadFromDb: profile id=$id, rowUid=$rowUid, currentUid=$currentUid');
        if (rowUid == null && currentUid != null) {
          final db = await DatabaseHelper.instance.database;
          await db.update('profiles', {'uid': currentUid}, where: 'id = ?', whereArgs: [id]);
          rowUid = currentUid;
          debugPrint('ProfileProvider._loadFromDb: updated profile $id uid to $currentUid');
        }
        if (id != preservedProfileId && currentUid != null && rowUid != currentUid) {
          debugPrint('ProfileProvider._loadFromDb: SKIPPED profile $id because rowUid ($rowUid) != currentUid ($currentUid)');
          continue;
        }

        final name = row['name'] as String;
        final type = row['type'] as String;

        // Clean up duplicate Personal profiles (only keep 'default_profile' as the main profile)
        final isDuplicatePersonal = id != 'default_profile' &&
            (name == 'Personal' || name == 'Personal Account' || name == 'Personal Finance') &&
            _profiles.any((p) => p.id == 'default_profile');

        if (isDuplicatePersonal) {
          await DatabaseHelper.instance.deleteProfileAndData(id);
          continue;
        }

        if (_profiles.any((p) => p.id == id)) {
          debugPrint('ProfileProvider._loadFromDb: skipping duplicate -> $id');
          continue;
        }

        _profiles.add(UserProfile(
          id: id,
          name: name,
          type: type,
          uid: currentUid ?? rowUid,
        ));
        _knownProfileIds.add(id);
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
          'uid': currentUid,
        });
        await _profileDoc('default_profile')?.set({
          'name': name,
          'type': 'Personal',
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        final match = _profiles.where((p) => p.id == preservedProfileId);
        if (match.isNotEmpty) {
          _currentProfile = match.first;
        } else {
          // Saved id is gone (deleted profile) — fall back to main, then first.
          // Never silently adopt a random secondary when prefs still say main.
          final defaultMatch = _profiles.where((p) => p.id == 'default_profile');
          _currentProfile =
              defaultMatch.isNotEmpty ? defaultMatch.first : _profiles.first;
          await SharedPrefsHelper.setString(
            SharedPrefsHelper.activeProfileKey,
            _currentProfile.id,
          );
          debugPrint(
            'ProfileProvider._loadFromDb: saved "$preservedProfileId" missing → '
            'fallback ${_currentProfile.id}',
          );
        }
      }

      // Do NOT rewrite prefs when the saved id was found. Overwriting
      // active_profile_id here used to clobber "main" with a secondary
      // whenever default_profile was briefly missing from the loaded list.

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
    // Cancel the Firestore listener before reloading to prevent it from
    // firing mid-reload with stale _knownProfileIds and corrupting state.
    _profileSubscription?.cancel();
    _profileSubscription = null;

    _loadingFuture = _loadFromDb(force: true);
    await _loadingFuture;

    // Re-attach the Firestore listener now that _knownProfileIds is populated
    // from the freshly loaded database state.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _attachProfileListener(uid);
    }
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
    _saveProfilesToPrefs();
    notifyListeners();
  }

  /// Align UI selection to [id] without rewriting SharedPrefs.
  /// Used when ProfileManager is already the source of truth.
  void syncCurrentProfileFromId(String id) {
    if (_currentProfile.id == id) return;
    final match = _profiles.where((p) => p.id == id);
    if (match.isEmpty) return;
    _currentProfile = match.first;
    notifyListeners();
  }

  /// Updates UI selection only. Persist via [ProfileManagerProvider.switchProfile]
  /// first so SharedPrefs / data-layer stay the source of truth.
  Future<void> selectProfile(UserProfile profile) async {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _currentProfile = _profiles[index];
    } else {
      _currentProfile = profile;
    }
    // Prefs are owned by ProfileManagerProvider.switchProfile — writing here
    // raced with _loadFromDb and could leave a stale secondary on next launch.
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
      type: 'Secondary',
      uid: currentUid,
    );

    debugPrint('ProfileProvider.finalizeProfileCreation: saving ${newProfile.name} (${newProfile.id})');

    _knownProfileIds.add(newProfile.id);

    try {
      await DatabaseHelper.instance.insertProfile({
        'id': newProfile.id,
        'name': newProfile.name,
        'type': newProfile.type,
        'createdAt': DateTime.now().toIso8601String(),
        'uid': currentUid,
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
    // Do not auto-activate the new secondary here. Caller must
    // ProfileManagerProvider.switchProfile + selectProfile so prefs/UI stay in sync.
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
    _knownProfileIds.remove(profileId);

    if (_currentProfile.id == profileId) {
      final defaultProfile = _profiles.firstWhere(
        (p) => p.id == 'default_profile',
        orElse: () => _profiles.isNotEmpty ? _profiles.first : UserProfile(
          id: 'default_profile', name: 'Personal', type: 'Personal', uid: FirebaseAuth.instance.currentUser?.uid,
        ),
      );
      _currentProfile = defaultProfile;
      await SharedPrefsHelper.setString(
        SharedPrefsHelper.activeProfileKey,
        defaultProfile.id,
      );
    }

    resetCreationState();
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}