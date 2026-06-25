import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class DebtItem {
  final String id;
  final String name;
  final String detail;
  final double amount;
  final bool isReceive; // true = To Receive, false = To Give
  final bool isSettled;
  final DateTime createdAt;
  final String? phone;
  final String? email;
  final String? address;
  final String? vat;

  DebtItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.amount,
    required this.isReceive,
    this.isSettled = false,
    required this.createdAt,
    this.phone,
    this.email,
    this.address,
    this.vat,
  });

  DebtItem copyWith({
    String? id,
    String? name,
    String? detail,
    double? amount,
    bool? isReceive,
    bool? isSettled,
    DateTime? createdAt,
    String? phone,
    String? email,
    String? address,
    String? vat,
  }) {
    return DebtItem(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      amount: amount ?? this.amount,
      isReceive: isReceive ?? this.isReceive,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      vat: vat ?? this.vat,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'detail': detail,
    'amount': amount,
    'isReceive': isReceive,
    'isSettled': isSettled,
    'phone': phone,
    'email': email,
    'address': address,
    'vat': vat,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DebtItem.fromMap(String id, Map<String, dynamic> map) => DebtItem(
    id: id,
    name: map['name'] as String,
    detail: map['detail'] as String? ?? '',
    amount: (map['amount'] as num).toDouble(),
    isReceive: map['isReceive'] as bool,
    isSettled: map['isSettled'] as bool? ?? false,
    createdAt: DateTime.parse(map['createdAt'] as String),
    phone: map['phone'] as String?,
    email: map['email'] as String?,
    address: map['address'] as String?,
    vat: map['vat'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'detail': detail,
    'amount': amount,
    'isReceive': isReceive ? 1 : 0,
    'isSettled': isSettled ? 1 : 0,
    'phone': phone,
    'email': email,
    'address': address,
    'vat': vat,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DebtItem.fromJson(Map<String, dynamic> json) => DebtItem(
    id: json['id'] as String,
    name: json['name'] as String,
    detail: json['detail'] as String? ?? '',
    amount: (json['amount'] as num).toDouble(),
    isReceive: (json['isReceive'] as int) == 1,
    isSettled: (json['isSettled'] as int) == 1,
    createdAt: DateTime.parse(json['createdAt'] as String),
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    vat: json['vat'] as String?,
  );
}

class DebtProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  final Set<String> _knownDocIds = {};
  final Set<String> _pendingIds = {};

  String? _currentUid;
  bool _isRetrying = false;

  final List<DebtItem> _items = [];

  DebtProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel();
      _knownDocIds.clear();
      _pendingIds.clear();
      if (user != null) {
        _startListening(user.uid);
      } else {
        _currentUid = null;
        _items.clear();
        notifyListeners();
      }
    });
  }

  void _startListening(String uid) {
    _currentUid = uid;
    notifyListeners();

    _loadFromDatabase().then((_) {
      _retryPendingOperations();
    });

    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('debt_items')
        .snapshots()
        .listen(
          (snapshot) {
            for (final change in snapshot.docChanges) {
              final docId = change.doc.id;
              switch (change.type) {
                case DocumentChangeType.added:
                  if (!_knownDocIds.contains(docId)) {
                    _knownDocIds.add(docId);
                    final item = DebtItem.fromMap(docId, change.doc.data()!);
                    _items.add(item);
                    _db.insertDebtItem(item, syncStatus: 'synced');
                  }
                  break;
                case DocumentChangeType.modified:
                  if (!_pendingIds.contains(docId)) {
                    final index = _items.indexWhere((d) => d.id == docId);
                    if (index != -1) {
                      _items[index] = DebtItem.fromMap(docId, change.doc.data()!);
                    }
                    _db.updateDebtItem(
                      DebtItem.fromMap(docId, change.doc.data()!),
                      syncStatus: 'synced',
                    );
                  }
                  break;
                case DocumentChangeType.removed:
                  _knownDocIds.remove(docId);
                  _pendingIds.remove(docId);
                  _items.removeWhere((d) => d.id == docId);
                  _db.hardDeleteDebtItem(docId);
                  break;
              }
            }
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Firestore debt_items snapshot listener error: $error');
            notifyListeners();
          },
        );
  }

  Future<void> _loadFromDatabase() async {
    try {
      final items = await _db.readAllDebtItems();
      _items.addAll(items);
      for (final item in items) {
        _knownDocIds.add(item.id);
      }
      final pendingIds = await _db.readAllPendingDebtIds();
      _pendingIds.addAll(pendingIds);
    } catch (e) {
      debugPrint('Error loading debt items from database: $e');
    }
    notifyListeners();
  }

  Future<void> _retryPendingOperations() async {
    if (_isRetrying) return;
    _isRetrying = true;
    try {
      final uid = _currentUid;
      if (uid == null) return;

      final pending = await _db.readPendingDebtSyncs();
      for (final item in pending) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('debt_items')
            .doc(item.id)
            .set(item.toMap())
            .then((_) {
              _db.markDebtSynced(item.id);
              _pendingIds.remove(item.id);
            })
            .catchError((_) {});
      }

      final deleteIds = await _db.readPendingDebtDeleteIds();
      for (final id in deleteIds) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('debt_items')
            .doc(id)
            .delete()
            .then((_) {
              _db.hardDeleteDebtItem(id);
              _pendingIds.remove(id);
            })
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('Retry pending debt operations error: $e');
    } finally {
      _isRetrying = false;
    }
  }

  List<DebtItem> get items => List.unmodifiable(_items);

  // Getters for To Receive
  List<DebtItem> get toReceiveUnpaid =>
      _items.where((i) => i.isReceive && !i.isSettled).toList();
  List<DebtItem> get toReceiveSettled =>
      _items.where((i) => i.isReceive && i.isSettled).toList();
  double get totalToReceive =>
      toReceiveUnpaid.fold(0.0, (sum, i) => sum + i.amount);

  // Getters for To Give
  List<DebtItem> get toGiveUnpaid =>
      _items.where((i) => !i.isReceive && !i.isSettled).toList();
  List<DebtItem> get toGiveSettled =>
      _items.where((i) => !i.isReceive && i.isSettled).toList();
  double get totalToGive =>
      toGiveUnpaid.fold(0.0, (sum, i) => sum + i.amount);

  void addDebtItem(DebtItem item) {
    final user = _auth.currentUser;
    if (user == null) return;

    _db.insertDebtItem(item, syncStatus: 'pending_create');
    _knownDocIds.add(item.id);
    _pendingIds.add(item.id);
    _items.insert(0, item);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('debt_items')
        .doc(item.id)
        .set(item.toMap())
        .then((_) async {
          _pendingIds.remove(item.id);
          await _db.markDebtSynced(item.id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore addDebtItem error: $error');
        });
  }

  void settleDebtItem(String id) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final updated = _items[index].copyWith(isSettled: true);
    _updateLocalAndFirestore(updated, index);
  }

  void toggleSettledStatus(String id) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final updated = _items[index].copyWith(isSettled: !_items[index].isSettled);
    _updateLocalAndFirestore(updated, index);
  }

  void deleteDebtItem(String id) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    _db.softDeleteDebtItem(id);
    _knownDocIds.remove(id);
    _pendingIds.add(id);
    _items.removeAt(index);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('debt_items')
        .doc(id)
        .delete()
        .then((_) async {
          _pendingIds.remove(id);
          await _db.hardDeleteDebtItem(id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore deleteDebtItem error: $error');
        });
  }

  void updateDebtItem(DebtItem updatedItem) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index == -1) return;

    _updateLocalAndFirestore(updatedItem, index);
  }

  void _updateLocalAndFirestore(DebtItem updated, int index) {
    final user = _auth.currentUser;
    if (user == null) return;

    _db.updateDebtItem(updated, syncStatus: 'pending_update');
    _pendingIds.add(updated.id);
    _items[index] = updated;
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('debt_items')
        .doc(updated.id)
        .update(updated.toMap())
        .then((_) async {
          _pendingIds.remove(updated.id);
          await _db.markDebtSynced(updated.id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore updateDebtItem error: $error');
        });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
