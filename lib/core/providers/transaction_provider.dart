import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class TransactionItem {
  final String id;
  final double amount;
  final String category;
  final String note;
  final bool isIncome;
  final DateTime dateTime;
  final String? incomeMonth;
  final String paymentMethod; // 'Cash' or 'Bank'
  final DateTime lastModified;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.isIncome,
    required this.dateTime,
    this.incomeMonth,
    this.paymentMethod = 'Cash',
    DateTime? lastModified,
  }) : lastModified = lastModified ?? dateTime;

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'category': category,
        'note': note,
        'isIncome': isIncome,
        'dateTime': dateTime.toIso8601String(),
        'incomeMonth': incomeMonth,
        'paymentMethod': paymentMethod,
        'lastModified': lastModified.toIso8601String(),
      };

  factory TransactionItem.fromMap(String id, Map<String, dynamic> map) =>
      TransactionItem(
        id: id,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        note: map['note'] as String? ?? '',
        isIncome: map['isIncome'] as bool,
        dateTime: DateTime.parse(map['dateTime'] as String),
        incomeMonth: map['incomeMonth'] as String?,
        paymentMethod: map['paymentMethod'] as String? ?? 'Cash',
        lastModified: map['lastModified'] != null
            ? DateTime.parse(map['lastModified'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'note': note,
        'isIncome': isIncome ? 1 : 0,
        'dateTime': dateTime.toIso8601String(),
        'incomeMonth': incomeMonth,
        'paymentMethod': paymentMethod,
        'lastModified': lastModified.toIso8601String(),
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      TransactionItem(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        note: json['note'] as String? ?? '',
        isIncome: (json['isIncome'] as int) == 1,
        dateTime: DateTime.parse(json['dateTime'] as String),
        incomeMonth: json['incomeMonth'] as String?,
        paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
        lastModified: json['lastModified'] != null
            ? DateTime.parse(json['lastModified'] as String)
            : null,
      );
}

enum TransactionSortOption {
  latest,
  amountHighToLow,
  amountLowToHigh;
}

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  final Set<String> _knownDocIds = {};
  final Set<String> _pendingIds = {};

  bool _isLoading = true;
  String? _currentUid;
  bool _isRetrying = false;

  final List<String> _expenseCategories = [];
  final List<String> _incomeCategories = [];
  final List<TransactionItem> _transactions = [];

  // Month, Search, and Sort states
  late final List<DateTime> availableMonths;
  int selectedMonthIndex = 6; // Center (current month)
  bool isSearching = false;
  String searchQuery = '';
  TransactionSortOption sortOption = TransactionSortOption.latest;

  TransactionProvider() {
    // Generate 12 months centered around the current month (index 6 is current)
    final now = DateTime.now();
    availableMonths = List.generate(12, (index) {
      return DateTime(now.year, now.month - 6 + index);
    });

    // Listen to auth changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel();
      _knownDocIds.clear();
      _pendingIds.clear();
      if (user != null) {
        _startListening(user.uid);
      } else {
        _currentUid = null;
        _transactions.clear();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _startListening(String uid) {
    _currentUid = uid;
    _isLoading = true;
    notifyListeners();

    // 1. Load from SQLite immediately
    _loadFromDatabase().then((_) {
      // 2. Retry any pending operations
      _retryPendingOperations();
    });

    // 3. Attach Firestore snapshot for ongoing sync
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final docId = change.doc.id;
          switch (change.type) {
            case DocumentChangeType.added:
              if (!_knownDocIds.contains(docId)) {
                _knownDocIds.add(docId);
                final item =
                    TransactionItem.fromMap(docId, change.doc.data()!);
                _transactions.add(item);
                _db.insertTransaction(item, syncStatus: 'synced');
              }
              break;
            case DocumentChangeType.modified:
              if (!_pendingIds.contains(docId)) {
                final index =
                    _transactions.indexWhere((t) => t.id == docId);
                if (index != -1) {
                  _transactions[index] =
                      TransactionItem.fromMap(docId, change.doc.data()!);
                }
                _db.updateTransaction(
                  TransactionItem.fromMap(docId, change.doc.data()!),
                  syncStatus: 'synced',
                );
              }
              break;
            case DocumentChangeType.removed:
              _knownDocIds.remove(docId);
              _pendingIds.remove(docId);
              _transactions.removeWhere((t) => t.id == docId);
              _db.hardDeleteTransaction(docId);
              break;
          }
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Firestore snapshot listener error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadFromDatabase() async {
    try {
      final items = await _db.readAllTransactions();
      _transactions.addAll(items);
      for (final item in items) {
        _knownDocIds.add(item.id);
      }
      // Protect pending local changes from snapshot overwrites
      final pendingIds = await _db.readAllPendingIds();
      _pendingIds.addAll(pendingIds);
    } catch (e) {
      debugPrint('Error loading transactions from database: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _retryPendingOperations() async {
    if (_isRetrying) return;
    _isRetrying = true;
    try {
      final uid = _currentUid;
      if (uid == null) return;

      final pending = await _db.readPendingSyncs();
      for (final item in pending) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(item.id)
            .set(item.toMap())
            .then((_) {
          _db.markSynced(item.id);
          _pendingIds.remove(item.id);
        }).catchError((_) {});
      }

      final deleteIds = await _db.readPendingDeleteIds();
      for (final id in deleteIds) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(id)
            .delete()
            .then((_) {
          _db.hardDeleteTransaction(id);
          _pendingIds.remove(id);
        }).catchError((_) {});
      }
    } catch (e) {
      debugPrint('Retry pending operations error: $e');
    } finally {
      _isRetrying = false;
    }
  }

  bool get isLoading => _isLoading;

  List<String> get expenseCategories => List.unmodifiable(_expenseCategories);
  List<String> get incomeCategories => List.unmodifiable(_incomeCategories);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  // Getters for selected month and active transactions
  DateTime get selectedMonth => availableMonths[selectedMonthIndex];

  List<TransactionItem> get monthlyTransactions {
    final month = selectedMonth;
    return _transactions.where((tx) {
      return tx.dateTime.year == month.year && tx.dateTime.month == month.month;
    }).toList();
  }

  List<TransactionItem> get filteredTransactions {
    final monthTrans = monthlyTransactions;
    List<TransactionItem> results;
    if (!isSearching || searchQuery.trim().isEmpty) {
      results = List.from(monthTrans);
    } else {
      final query = searchQuery.toLowerCase().trim();
      results = monthTrans.where((tx) {
        return tx.note.toLowerCase().contains(query) ||
            tx.category.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    switch (sortOption) {
      case TransactionSortOption.latest:
        results.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case TransactionSortOption.amountHighToLow:
        results.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSortOption.amountLowToHigh:
        results.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return results;
  }

  // Monthly stats calculations (based on month transactions before search query filter)
  double get monthlyIncome {
    return monthlyTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyExpense {
    return monthlyTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyNetBalance => monthlyIncome - monthlyExpense;

  // Actions
  void selectMonthIndex(int index) {
    if (index >= 0 && index < availableMonths.length) {
      selectedMonthIndex = index;
      notifyListeners();
    }
  }

  void updateSortOption(TransactionSortOption option) {
    sortOption = option;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void toggleSearching(bool value) {
    isSearching = value;
    if (!value) {
      searchQuery = '';
    }
    notifyListeners();
  }

  void addExpenseCategory(String category) {
    final cleanCategory = category.trim();
    if (cleanCategory.isNotEmpty && !_expenseCategories.contains(cleanCategory)) {
      _expenseCategories.add(cleanCategory);
      notifyListeners();
    }
  }

  void deleteExpenseCategory(String category) {
    if (_expenseCategories.contains(category)) {
      _expenseCategories.remove(category);
      notifyListeners();
    }
  }

  void addIncomeCategory(String category) {
    final cleanCategory = category.trim();
    if (cleanCategory.isNotEmpty && !_incomeCategories.contains(cleanCategory)) {
      _incomeCategories.add(cleanCategory);
      notifyListeners();
    }
  }

  void deleteIncomeCategory(String category) {
    if (_incomeCategories.contains(category)) {
      _incomeCategories.remove(category);
      notifyListeners();
    }
  }

  void addTransaction(TransactionItem transaction) {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc();

    final now = DateTime.now();
    final uniqueTransaction = TransactionItem(
      id: docRef.id,
      amount: transaction.amount,
      category: transaction.category,
      note: transaction.note,
      isIncome: transaction.isIncome,
      dateTime: transaction.dateTime,
      incomeMonth: transaction.incomeMonth,
      paymentMethod: transaction.paymentMethod,
      lastModified: now,
    );

    // 1. SQLite first (always succeeds locally)
    _db.insertTransaction(uniqueTransaction, syncStatus: 'pending_create');

    // 2. Update local state
    _knownDocIds.add(uniqueTransaction.id);
    _pendingIds.add(uniqueTransaction.id);
    _transactions.insert(0, uniqueTransaction);
    notifyListeners();

    // 3. Try Firestore — never rollback SQLite on failure
    docRef.set(uniqueTransaction.toMap()).then((_) async {
      _pendingIds.remove(uniqueTransaction.id);
      await _db.markSynced(uniqueTransaction.id);
      _retryPendingOperations();
    }).catchError((error) {
      debugPrint('Firestore addTransaction error: $error');
    });
  }

  void transferBalance(double amount, String fromAccount, String toAccount) {
    final user = _auth.currentUser;
    if (user == null) return;

    final txRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');

    final now = DateTime.now();
    final expenseItem = TransactionItem(
      id: txRef.doc().id,
      amount: amount,
      category: 'Transfer',
      note: 'Transfer to $toAccount',
      isIncome: false,
      dateTime: now,
      paymentMethod: fromAccount,
      lastModified: now,
    );

    final incomeItem = TransactionItem(
      id: txRef.doc().id,
      amount: amount,
      category: 'Transfer',
      note: 'Transfer from $fromAccount',
      isIncome: true,
      dateTime: now,
      paymentMethod: toAccount,
      lastModified: now,
    );

    // 1. SQLite first
    _db.insertTransaction(expenseItem, syncStatus: 'pending_create');
    _db.insertTransaction(incomeItem, syncStatus: 'pending_create');

    // 2. Local state
    _knownDocIds.add(expenseItem.id);
    _knownDocIds.add(incomeItem.id);
    _pendingIds.add(expenseItem.id);
    _pendingIds.add(incomeItem.id);
    _transactions.insert(0, expenseItem);
    _transactions.insert(0, incomeItem);
    notifyListeners();

    // 3. Try Firestore
    final batch = _firestore.batch();
    batch.set(txRef.doc(expenseItem.id), expenseItem.toMap());
    batch.set(txRef.doc(incomeItem.id), incomeItem.toMap());
    batch.commit().then((_) async {
      _pendingIds.remove(expenseItem.id);
      _pendingIds.remove(incomeItem.id);
      await _db.markSynced(expenseItem.id);
      await _db.markSynced(incomeItem.id);
      _retryPendingOperations();
    }).catchError((error) {
      debugPrint('Firestore transferBalance error: $error');
    });
  }

  void deleteTransaction(String id) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    // 1. SQLite first
    _db.softDeleteTransaction(id);

    // 2. Local state
    _knownDocIds.remove(id);
    _pendingIds.add(id);
    _transactions.removeAt(index);
    notifyListeners();

    // 3. Try Firestore
    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete()
        .then((_) async {
      _pendingIds.remove(id);
      await _db.hardDeleteTransaction(id);
      _retryPendingOperations();
    }).catchError((error) {
      debugPrint('Firestore deleteTransaction error: $error');
    });
  }

  void updateTransaction(TransactionItem transaction) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) return;

    final updated = TransactionItem(
      id: transaction.id,
      amount: transaction.amount,
      category: transaction.category,
      note: transaction.note,
      isIncome: transaction.isIncome,
      dateTime: transaction.dateTime,
      incomeMonth: transaction.incomeMonth,
      paymentMethod: transaction.paymentMethod,
      lastModified: DateTime.now(),
    );

    // 1. SQLite first
    _db.updateTransaction(updated, syncStatus: 'pending_update');

    // 2. Local state
    _pendingIds.add(updated.id);
    _transactions[index] = updated;
    notifyListeners();

    // 3. Try Firestore
    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(updated.id)
        .update(updated.toMap())
        .then((_) async {
      _pendingIds.remove(updated.id);
      await _db.markSynced(updated.id);
      _retryPendingOperations();
    }).catchError((error) {
      debugPrint('Firestore updateTransaction error: $error');
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}

