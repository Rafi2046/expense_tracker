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
  final bool isReceive;
  final bool isSettled;
  final DateTime createdAt;
  final String? phone;
  final String? email;
  final String? address;
  final String? vat;
  final String profileId;

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
    this.profileId = 'default_profile',
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
    String? profileId,
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
      profileId: profileId ?? this.profileId,
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
    'profileId': profileId,
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
    profileId: map['profileId'] as String? ?? 'default_profile',
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
    'profileId': profileId,
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
    profileId: json['profileId'] as String? ?? 'default_profile',
  );
}

class DebtProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  final Set<String> _knownDocIds = {};
  final Set<String> _pendingIds = {};

  bool _isRetrying = false;

  String _activeProfileId;

  final List<DebtItem> _items = [];

  DebtProvider({required String initialProfileId})
      : _activeProfileId = initialProfileId {
    _authSubscription = _auth.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    final uidChanged = newUser?.uid != _firebaseUser?.uid;
    final previousUser = _firebaseUser;
    _firebaseUser = newUser;

    if (newUser == null) {
      _firestoreSubscription?.cancel();
      _firestoreSubscription = null;
      _knownDocIds.clear();
      _pendingIds.clear();
      _items.clear();
      notifyListeners();
      _db.clearUserData();
      return;
    }

    // Ignore token-refresh noise from userChanges().
    if (!uidChanged && previousUser != null && _firestoreSubscription != null) {
      return;
    }

    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;

    () async {
      // Only wipe when switching between two real accounts — never on cold start.
      if (uidChanged && previousUser != null) {
        _knownDocIds.clear();
        _pendingIds.clear();
        _items.clear();
        notifyListeners();
        await _db.clearUserData();
      }
      await _startListening(newUser.uid);
    }();
  }

  Future<void> _startListening(String uid) async {
    _items.clear();
    _knownDocIds.clear();
    _pendingIds.clear();
    notifyListeners();

    await _loadFromDatabase();
    _retryPendingOperations();
    _attachDebtListener(uid);
  }

  Future<void> forceReload() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    await _startListening(uid);
  }

  void _attachDebtListener(String uid) {
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
                    _db.insertDebtItem(item, syncStatus: 'synced', profileId: item.profileId);
                    if (item.profileId == _activeProfileId) {
                      _items.add(item);
                    }
                  }
                  break;
                case DocumentChangeType.modified:
                  if (!_pendingIds.contains(docId)) {
                    final item = DebtItem.fromMap(docId, change.doc.data()!);
                    _db.updateDebtItem(
                      item,
                      syncStatus: 'synced',
                      profileId: item.profileId,
                    );
                    final index = _items.indexWhere((d) => d.id == docId);
                    if (item.profileId == _activeProfileId) {
                      if (index != -1) {
                        _items[index] = item;
                      } else {
                        _items.add(item);
                      }
                    } else if (index != -1) {
                      _items.removeAt(index);
                    }
                  }
                  break;
                case DocumentChangeType.removed:
                  _knownDocIds.remove(docId);
                  _pendingIds.remove(docId);
                  _items.removeWhere((d) => d.id == docId);
                  _db.hardDeleteDebtItem(docId, profileId: _activeProfileId);
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
      final items = await _db.readAllDebtItems(profileId: _activeProfileId);
      _items.addAll(items);
      for (final item in items) {
        _knownDocIds.add(item.id);
      }
      final pendingIds = await _db.readAllPendingDebtIds(profileId: _activeProfileId);
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
      final uid = _firebaseUser?.uid;
      if (uid == null) return;

      final pending = await _db.readPendingDebtSyncs(profileId: _activeProfileId);
      for (final item in pending) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('debt_items')
            .doc(item.id)
            .set(item.toMap())
            .then((_) {
              _db.markDebtSynced(item.id, profileId: _activeProfileId);
              _pendingIds.remove(item.id);
            })
            .catchError((_) {});
      }

      final deleteIds = await _db.readPendingDebtDeleteIds(profileId: _activeProfileId);
      for (final id in deleteIds) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('debt_items')
            .doc(id)
            .delete()
            .then((_) {
              _db.hardDeleteDebtItem(id, profileId: _activeProfileId);
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

  String get activeProfileId => _activeProfileId;

  List<DebtItem> get items => List.unmodifiable(_items);

  List<DebtItem> get toReceiveUnpaid =>
      _items.where((i) => i.isReceive && !i.isSettled).toList();
  List<DebtItem> get toReceiveSettled =>
      _items.where((i) => i.isReceive && i.isSettled).toList();
  double get totalToReceive =>
      toReceiveUnpaid.fold(0.0, (total, i) => total + i.amount);

  List<DebtItem> get toGiveUnpaid =>
      _items.where((i) => !i.isReceive && !i.isSettled).toList();
  List<DebtItem> get toGiveSettled =>
      _items.where((i) => !i.isReceive && i.isSettled).toList();
  double get totalToGive =>
      toGiveUnpaid.fold(0.0, (total, i) => total + i.amount);

  void clear() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _knownDocIds.clear();
    _pendingIds.clear();
    _items.clear();
    _firebaseUser = null;
    notifyListeners();
  }

  void addDebtItem(DebtItem item) {
    final user = _firebaseUser;
    if (user == null) return;

    final profileStampedItem = item.copyWith(profileId: _activeProfileId);
    _db.insertDebtItem(profileStampedItem, syncStatus: 'pending_create', profileId: _activeProfileId);
    _knownDocIds.add(profileStampedItem.id);
    _pendingIds.add(profileStampedItem.id);
    _items.insert(0, profileStampedItem);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('debt_items')
        .doc(profileStampedItem.id)
        .set(profileStampedItem.toMap())
        .then((_) async {
          _pendingIds.remove(item.id);
          await _db.markDebtSynced(item.id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore addDebtItem error: $error');
        });
  }

  void settleDebtItem(String id) {
    final user = _firebaseUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final updated = _items[index].copyWith(isSettled: true);
    _updateLocalAndFirestore(updated, index);
  }

  void toggleSettledStatus(String id) {
    final user = _firebaseUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final updated = _items[index].copyWith(isSettled: !_items[index].isSettled);
    _updateLocalAndFirestore(updated, index);
  }

  void deleteDebtItem(String id) {
    final user = _firebaseUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    _db.softDeleteDebtItem(id, profileId: _activeProfileId);
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
          await _db.hardDeleteDebtItem(id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore deleteDebtItem error: $error');
        });
  }

  void updateDebtItem(DebtItem updatedItem) {
    final user = _firebaseUser;
    if (user == null) return;

    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index == -1) return;

    _updateLocalAndFirestore(updatedItem, index);
  }

  void _updateLocalAndFirestore(DebtItem updated, int index) {
    final user = _firebaseUser;
    if (user == null) return;

    _db.updateDebtItem(updated, syncStatus: 'pending_update', profileId: _activeProfileId);
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
          await _db.markDebtSynced(updated.id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore updateDebtItem error: $error');
        });
  }

  void updateProfileId(String id) {
    if (id == _activeProfileId) return;
    debugPrint('DebtProvider.updateProfileId: switching to $id');
    _activeProfileId = id;
    _firestoreSubscription?.cancel();
    _knownDocIds.clear();
    _pendingIds.clear();
    _items.clear();
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
