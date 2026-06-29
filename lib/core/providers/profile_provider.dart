import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final List<UserProfile> _profiles = [];
  late UserProfile _currentProfile;

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

  ProfileProvider() {
    _initProfiles();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (user.email != null && user.email!.contains('@') ? user.email!.split('@').first : 'Personal Account');
        syncDefaultProfileName(name);
      }
    });
  }

  void _initProfiles() {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (user?.email != null && user!.email!.contains('@') ? user.email!.split('@').first : 'Personal Account');

    _profiles.clear();
    _profiles.add(UserProfile(id: 'default_profile', name: name, type: 'Personal'));
    _currentProfile = _profiles.first;
  }

  void syncDefaultProfileName(String name) {
    final idx = _profiles.indexWhere((p) => p.id == 'default_profile');
    if (idx != -1) {
      final old = _profiles[idx];
      if (old.name != name) {
        _profiles[idx] = UserProfile(id: old.id, name: name, type: old.type);
        if (_currentProfile.id == 'default_profile') {
          _currentProfile = _profiles[idx];
        }
        notifyListeners();
      }
    }
  }

  // Getters
  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  UserProfile get currentProfile => _currentProfile;

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

  // Setters & Actions
  void addProfile(UserProfile profile) {
    _profiles.add(profile);
    _currentProfile = profile;
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

  UserProfile finalizeProfileCreation() {
    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _creationName.trim(),
      type: _creationProfileType == 'business'
          ? 'Business ($_selectedCategory)'
          : 'Personal',
    );
    _profiles.add(newProfile);
    _currentProfile = newProfile;
    resetCreationState();
    notifyListeners();
    return newProfile;
  }
}
