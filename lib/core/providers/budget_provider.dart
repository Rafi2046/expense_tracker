import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  bool _isLoading = true;
  double _amount = 0;
  String _activeProfileId = 'default_profile';

  BudgetProvider() {
    _authSubscription = _auth.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    _firebaseUser = newUser;

    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;

    if (newUser == null) {
      _amount = 0;
      _isLoading = true;
      _db.clearUserData();
      notifyListeners();
      return;
    }

    _startListening(newUser.uid);
  }

  String get activeProfileId => _activeProfileId;

  double get amount => _amount;
  bool get isLoading => _isLoading;
  bool get hasBudget => _amount > 0;

  void _startListening(String uid) {
    _isLoading = true;
    notifyListeners();

    _loadFromDatabase().then((_) {
      _retryPendingBudget();
      _attachBudgetListener(uid);
    });
  }

  void _attachBudgetListener(String uid) {
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('budget')
        .doc('monthly_$_activeProfileId')
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          final remoteAmount = (snapshot.data()!['amount'] as num).toDouble();
          if (remoteAmount != _amount) {
            _amount = remoteAmount;
            _db.insertOrUpdateBudget(_amount, syncStatus: 'synced', profileId: _activeProfileId);
            notifyListeners();
          }
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Budget snapshot listener error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadFromDatabase() async {
    try {
      final budgetAmount = await _db.readBudget(profileId: _activeProfileId);
      if (budgetAmount != null) {
        _amount = budgetAmount;
      }
    } catch (e) {
      debugPrint('Error loading budget from database: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _retryPendingBudget() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;

    try {
      final syncStatus = await _db.getBudgetSyncStatus(profileId: _activeProfileId);
      if (syncStatus == null || syncStatus == 'synced') return;

      _firestore
          .collection('users')
          .doc(uid)
          .collection('budget')
          .doc('monthly_$_activeProfileId')
          .set({'amount': _amount, 'lastModified': DateTime.now().toIso8601String()})
          .then((_) async {
        await _db.markBudgetSynced(profileId: _activeProfileId);
      }).catchError((error) {
        debugPrint('Retry pending budget error: $error');
      });
    } catch (e) {
      debugPrint('Retry pending budget error: $e');
    }
  }

  void clear() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _amount = 0;
    _isLoading = true;
    _firebaseUser = null;
    notifyListeners();
  }

  void setBudget(double amount) {
    final user = _firebaseUser;
    if (user == null) return;

    _amount = amount;

    _db.insertOrUpdateBudget(_amount, syncStatus: 'pending', profileId: _activeProfileId);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budget')
        .doc('monthly_$_activeProfileId')
        .set({'amount': _amount, 'lastModified': DateTime.now().toIso8601String()})
        .then((_) async {
      await _db.markBudgetSynced(profileId: _activeProfileId);
    }).catchError((error) {
      debugPrint('Firestore setBudget error: $error');
    });
  }

  void updateProfileId(String id) {
    debugPrint('BudgetProvider.updateProfileId: switching to $id');
    _activeProfileId = id;
    _firestoreSubscription?.cancel();
    _amount = 0;
    final uid = _firebaseUser?.uid;
    if (uid != null) {
      _startListening(uid);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
