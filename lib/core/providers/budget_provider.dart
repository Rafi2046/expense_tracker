import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class BudgetProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Fired after the budget amount changes (local or remote).
  static void Function(String profileId)? onBudgetChanged;

  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  bool _isLoading = true;
  double _amount = 0;
  String _activeProfileId;

  BudgetProvider({required String initialProfileId})
      : _activeProfileId = initialProfileId {
    _authSubscription = _auth.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    final previousUid = _firebaseUser?.uid;
    final previousUser = _firebaseUser;

    if (newUser == null) {
      _firestoreSubscription?.cancel();
      _firestoreSubscription = null;
      _firebaseUser = null;
      _amount = 0;
      _isLoading = true;
      notifyListeners();
      _db.clearUserData();
      return;
    }

    final uidChanged = newUser.uid != previousUid;
    _firebaseUser = newUser;

    // Ignore token-refresh noise from userChanges().
    if (!uidChanged && previousUser != null && _firestoreSubscription != null) {
      return;
    }

    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;

    // Drop any stale limit immediately so the UI cannot paint red/green
    // from a previous session while SQLite/Firestore are still hydrating.
    _amount = 0;
    _isLoading = true;
    notifyListeners();

    () async {
      // Only wipe when switching between two real accounts — never on cold start
      // (null → logged-in user), or profiles/transactions vanish and prefs restore
      // can land on a secondary profile.
      if (uidChanged && previousUser != null) {
        // Join/await the same wipe TransactionProvider starts on auth.
        await _db.clearUserData();
      }
      await _startListening(newUser.uid);
    }();
  }

  String get activeProfileId => _activeProfileId;

  double get amount => _amount;
  bool get isLoading => _isLoading;
  bool get hasBudget => _amount > 0;

  Future<void> _startListening(String uid) async {
    _isLoading = true;
    notifyListeners();

    await _loadFromDatabase();
    _retryPendingBudget();
    _attachBudgetListener(uid);
  }

  Future<void> forceReload() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _amount = 0;
    _isLoading = true;
    notifyListeners();
    await _startListening(uid);
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
            onBudgetChanged?.call(_activeProfileId);
          }
        } else {
          // Remote doc missing — do not keep a stale local limit.
          if (_amount != 0) {
            _amount = 0;
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
      // Always assign — never leave a previous session's amount when SQLite is empty.
      _amount = budgetAmount ?? 0;
    } catch (e) {
      debugPrint('Error loading budget from database: $e');
      _amount = 0;
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

    onBudgetChanged?.call(_activeProfileId);
  }

  void updateProfileId(String id) {
    if (id == _activeProfileId) return;
    debugPrint('BudgetProvider.updateProfileId: switching to $id');
    _activeProfileId = id;
    _firestoreSubscription?.cancel();
    _amount = 0;
    _isLoading = true;
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
