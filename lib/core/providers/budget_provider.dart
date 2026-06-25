import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  bool _isLoading = true;
  String? _currentUid;
  double _amount = 0;

  BudgetProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel();
      if (user != null) {
        _startListening(user.uid);
      } else {
        _currentUid = null;
        _amount = 0;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  double get amount => _amount;
  bool get isLoading => _isLoading;
  bool get hasBudget => _amount > 0;

  void _startListening(String uid) {
    _currentUid = uid;
    _isLoading = true;
    notifyListeners();

    _loadFromDatabase().then((_) {
      _retryPendingBudget();
    });

    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('budget')
        .doc('monthly')
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          final remoteAmount = (snapshot.data()!['amount'] as num).toDouble();
          if (remoteAmount != _amount) {
            _amount = remoteAmount;
            _db.insertOrUpdateBudget(_amount, syncStatus: 'synced');
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
      final budgetAmount = await _db.readBudget();
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
    final uid = _currentUid;
    if (uid == null) return;

    try {
      final syncStatus = await _db.getBudgetSyncStatus();
      if (syncStatus == null || syncStatus == 'synced') return;

      _firestore
          .collection('users')
          .doc(uid)
          .collection('budget')
          .doc('monthly')
          .set({'amount': _amount, 'lastModified': DateTime.now().toIso8601String()})
          .then((_) async {
        await _db.markBudgetSynced();
      }).catchError((error) {
        debugPrint('Retry pending budget error: $error');
      });
    } catch (e) {
      debugPrint('Retry pending budget error: $e');
    }
  }

  void setBudget(double amount) {
    final user = _auth.currentUser;
    if (user == null) return;

    _amount = amount;

    _db.insertOrUpdateBudget(_amount, syncStatus: 'pending');
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('budget')
        .doc('monthly')
        .set({'amount': _amount, 'lastModified': DateTime.now().toIso8601String()})
        .then((_) async {
      await _db.markBudgetSynced();
    }).catchError((error) {
      debugPrint('Firestore setBudget error: $error');
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
