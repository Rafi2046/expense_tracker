import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  final List<UserProfile> _profiles = [
    UserProfile(id: '1', name: 'Rafi', type: 'Personal'),
    UserProfile(id: '2', name: 'Office', type: 'Business'),
  ];

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
    _currentProfile = _profiles.first;
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
    if (_profiles.contains(profile)) {
      _currentProfile = profile;
      notifyListeners();
    }
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
