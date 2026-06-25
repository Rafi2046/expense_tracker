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

class CategoryItem {
  final String id;
  final String name;
  final bool isIncome;
  final DateTime lastModified;

  CategoryItem({
    required this.id,
    required this.name,
    required this.isIncome,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'name': name,
    'isIncome': isIncome,
    'lastModified': lastModified.toIso8601String(),
  };

  factory CategoryItem.fromMap(String id, Map<String, dynamic> map) =>
      CategoryItem(
        id: id,
        name: map['name'] as String,
        isIncome: map['isIncome'] as bool,
        lastModified: map['lastModified'] != null
            ? DateTime.parse(map['lastModified'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isIncome': isIncome ? 1 : 0,
    'lastModified': lastModified.toIso8601String(),
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    isIncome: (json['isIncome'] as int) == 1,
    lastModified: json['lastModified'] != null
        ? DateTime.parse(json['lastModified'] as String)
        : null,
  );
}

enum TransactionSortOption { latest, amountHighToLow, amountLowToHigh }

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  StreamSubscription<QuerySnapshot>? _categorySubscription;
  final Set<String> _knownDocIds = {};
  final Set<String> _pendingIds = {};
  final Set<String> _knownCategoryIds = {};
  final Set<String> _pendingCategoryIds = {};

  bool _isLoading = true;
  String? _currentUid;
  bool _isRetrying = false;

  final List<CategoryItem> _categoryItems = [];
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
      _categorySubscription?.cancel();
      _knownDocIds.clear();
      _pendingIds.clear();
      _knownCategoryIds.clear();
      _pendingCategoryIds.clear();
      if (user != null) {
        _startListening(user.uid);
      } else {
        _currentUid = null;
        _transactions.clear();
        _categoryItems.clear();
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
      _loadCategoriesFromDatabase().then((_) {
        _retryPendingOperations();
      });
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
                    final item = TransactionItem.fromMap(
                      docId,
                      change.doc.data()!,
                    );
                    _transactions.add(item);
                    _db.insertTransaction(item, syncStatus: 'synced');
                  }
                  break;
                case DocumentChangeType.modified:
                  if (!_pendingIds.contains(docId)) {
                    final index = _transactions.indexWhere(
                      (t) => t.id == docId,
                    );
                    if (index != -1) {
                      _transactions[index] = TransactionItem.fromMap(
                        docId,
                        change.doc.data()!,
                      );
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
    // 4. Attach Firestore snapshot for categories
    _categorySubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .snapshots()
        .listen(
          (snapshot) {
            for (final change in snapshot.docChanges) {
              final docId = change.doc.id;
              switch (change.type) {
                case DocumentChangeType.added:
                  if (!_knownCategoryIds.contains(docId)) {
                    _knownCategoryIds.add(docId);
                    final item = CategoryItem.fromMap(
                      docId,
                      change.doc.data()!,
                    );
                    _categoryItems.add(item);
                    _db.insertCategory(item, syncStatus: 'synced');
                  }
                  break;
                case DocumentChangeType.removed:
                  _knownCategoryIds.remove(docId);
                  _pendingCategoryIds.remove(docId);
                  _categoryItems.removeWhere((c) => c.id == docId);
                  _db.hardDeleteCategory(docId);
                  break;
                case DocumentChangeType.modified:
                  break;
              }
            }
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Firestore categories snapshot listener error: $error');
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

  Future<void> _loadCategoriesFromDatabase() async {
    try {
      final items = await _db.readAllCategories();
      _categoryItems.addAll(items);
      for (final item in items) {
        _knownCategoryIds.add(item.id);
      }
      final pendingIds = await _db.readAllPendingCategoryIds();
      _pendingCategoryIds.addAll(pendingIds);
    } catch (e) {
      debugPrint('Error loading categories from database: $e');
    }
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
            })
            .catchError((_) {});
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
            })
            .catchError((_) {});
      }

      // Retry pending category creates
      final pendingCategories = await _db.readPendingCategorySyncs();
      for (final item in pendingCategories) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('categories')
            .doc(item.id)
            .set(item.toMap())
            .then((_) {
              _db.markCategorySynced(item.id);
              _pendingCategoryIds.remove(item.id);
            })
            .catchError((_) {});
      }

      // Retry pending category deletes
      final deleteCategoryIds = await _db.readPendingCategoryDeleteIds();
      for (final id in deleteCategoryIds) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('categories')
            .doc(id)
            .delete()
            .then((_) {
              _db.hardDeleteCategory(id);
              _pendingCategoryIds.remove(id);
            })
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('Retry pending operations error: $e');
    } finally {
      _isRetrying = false;
    }
  }

  bool get isLoading => _isLoading;

  List<String> get expenseCategories => List.unmodifiable(
    _categoryItems.where((c) => !c.isIncome).map((c) => c.name),
  );

  List<String> get incomeCategories => List.unmodifiable(
    _categoryItems.where((c) => c.isIncome).map((c) => c.name),
  );

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

  // ─── Analytics Getters ─────────────────────────────────────────

  Map<String, double> get categoryExpenseBreakdown {
    final Map<String, double> breakdown = {};
    final Map<String, String> normalizedKeys = {};
    for (final tx in monthlyTransactions.where((t) => !t.isIncome)) {
      final normalized = tx.category.toLowerCase();
      normalizedKeys.putIfAbsent(normalized, () => tx.category);
      breakdown.update(normalized, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    return {for (final k in breakdown.keys) normalizedKeys[k]!: breakdown[k]!};
  }

  List<TransactionItem> get previousMonthTransactions {
    final month = selectedMonth;
    final prev = DateTime(month.year, month.month - 1, 1);
    return _transactions
        .where(
          (tx) =>
              tx.dateTime.year == prev.year && tx.dateTime.month == prev.month,
        )
        .toList();
  }

  double get previousMonthExpense {
    return previousMonthTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousMonthIncome {
    return previousMonthTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get expenseChangePercent {
    if (previousMonthExpense == 0) return monthlyExpense > 0 ? 100 : 0;
    return ((monthlyExpense - previousMonthExpense) / previousMonthExpense) *
        100;
  }

  double get incomeChangePercent {
    if (previousMonthIncome == 0) return monthlyIncome > 0 ? 100 : 0;
    return ((monthlyIncome - previousMonthIncome) / previousMonthIncome) * 100;
  }

  List<(String, double, double)> topSpendingCategories([int limit = 5]) {
    final breakdown = categoryExpenseBreakdown;
    final total = monthlyExpense;
    if (total == 0) return [];

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((e) => (e.key, e.value, (e.value / total) * 100))
        .toList();
  }

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
    if (cleanCategory.isEmpty) return;
    if (_categoryItems.any(
      (c) => c.name.toLowerCase() == cleanCategory.toLowerCase() && !c.isIncome,
    )) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc();
    final now = DateTime.now();
    final item = CategoryItem(
      id: docRef.id,
      name: cleanCategory,
      isIncome: false,
      lastModified: now,
    );

    _db.insertCategory(item, syncStatus: 'pending_create');
    _knownCategoryIds.add(item.id);
    _pendingCategoryIds.add(item.id);
    _categoryItems.add(item);
    notifyListeners();

    docRef
        .set(item.toMap())
        .then((_) async {
          _pendingCategoryIds.remove(item.id);
          await _db.markCategorySynced(item.id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore addExpenseCategory error: $error');
        });
  }

  void deleteExpenseCategory(String category) {
    final user = _auth.currentUser;
    if (user == null) return;

    final idx = _categoryItems
        .indexWhere((c) => c.name == category && !c.isIncome);
    if (idx == -1) return;

    final item = _categoryItems[idx];

    _db.softDeleteCategory(item.id);
    _knownCategoryIds.remove(item.id);
    _pendingCategoryIds.add(item.id);
    _categoryItems.removeAt(idx);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc(item.id)
        .delete()
        .then((_) async {
          _pendingCategoryIds.remove(item.id);
          await _db.hardDeleteCategory(item.id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore deleteExpenseCategory error: $error');
        });
  }

  void addIncomeCategory(String category) {
    final cleanCategory = category.trim();
    if (cleanCategory.isEmpty) return;
    if (_categoryItems.any(
      (c) => c.name.toLowerCase() == cleanCategory.toLowerCase() && c.isIncome,
    )) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc();
    final now = DateTime.now();
    final item = CategoryItem(
      id: docRef.id,
      name: cleanCategory,
      isIncome: true,
      lastModified: now,
    );

    _db.insertCategory(item, syncStatus: 'pending_create');
    _knownCategoryIds.add(item.id);
    _pendingCategoryIds.add(item.id);
    _categoryItems.add(item);
    notifyListeners();

    docRef
        .set(item.toMap())
        .then((_) async {
          _pendingCategoryIds.remove(item.id);
          await _db.markCategorySynced(item.id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore addIncomeCategory error: $error');
        });
  }

  void deleteIncomeCategory(String category) {
    final user = _auth.currentUser;
    if (user == null) return;

    final idx =
        _categoryItems.indexWhere((c) => c.name == category && c.isIncome);
    if (idx == -1) return;

    final item = _categoryItems[idx];

    _db.softDeleteCategory(item.id);
    _knownCategoryIds.remove(item.id);
    _pendingCategoryIds.add(item.id);
    _categoryItems.removeAt(idx);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc(item.id)
        .delete()
        .then((_) async {
          _pendingCategoryIds.remove(item.id);
          await _db.hardDeleteCategory(item.id);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore deleteIncomeCategory error: $error');
        });
  }

  void renameCategory(String oldName, String newName, {required bool isIncome}) {
    final cleanNewName = newName.trim();
    if (cleanNewName.isEmpty) return;
    if (oldName.trim().toLowerCase() == cleanNewName.toLowerCase()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    // 1. SQLite atomic cascade
    _db.renameCategory(oldName, cleanNewName, isIncome: isIncome);

    // 2. Update local category items
    CategoryItem? renamedCategory;
    for (int i = 0; i < _categoryItems.length; i++) {
      if (_categoryItems[i].name == oldName && _categoryItems[i].isIncome == isIncome) {
        renamedCategory = CategoryItem(
          id: _categoryItems[i].id,
          name: cleanNewName,
          isIncome: _categoryItems[i].isIncome,
          lastModified: DateTime.now(),
        );
        _categoryItems[i] = renamedCategory;
        _pendingCategoryIds.add(renamedCategory.id);
        break;
      }
    }

    // 3. Update local transactions
    final affectedTxIds = <String>[];
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].category == oldName) {
        final updated = TransactionItem(
          id: _transactions[i].id,
          amount: _transactions[i].amount,
          category: cleanNewName,
          note: _transactions[i].note,
          isIncome: _transactions[i].isIncome,
          dateTime: _transactions[i].dateTime,
          incomeMonth: _transactions[i].incomeMonth,
          paymentMethod: _transactions[i].paymentMethod,
          lastModified: DateTime.now(),
        );
        _transactions[i] = updated;
        _pendingIds.add(updated.id);
        affectedTxIds.add(updated.id);
      }
    }
    notifyListeners();

    // 4. Firestore batch
    final batch = _firestore.batch();
    if (renamedCategory != null) {
      batch.update(
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .doc(renamedCategory.id),
        renamedCategory.toMap(),
      );
    }
    for (final id in affectedTxIds) {
      final tx = _transactions.firstWhere((t) => t.id == id);
      batch.update(
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(id),
        tx.toMap(),
      );
    }

    batch.commit().then((_) async {
      if (renamedCategory != null) {
        _pendingCategoryIds.remove(renamedCategory.id);
        await _db.markCategorySynced(renamedCategory.id);
      }
      for (final id in affectedTxIds) {
        _pendingIds.remove(id);
        await _db.markSynced(id);
      }
      _retryPendingOperations();
    }).catchError((error) {
      debugPrint('Firestore renameCategory batch error: $error');
    });
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
    docRef
        .set(uniqueTransaction.toMap())
        .then((_) async {
          _pendingIds.remove(uniqueTransaction.id);
          await _db.markSynced(uniqueTransaction.id);
          _retryPendingOperations();
        })
        .catchError((error) {
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
    batch
        .commit()
        .then((_) async {
          _pendingIds.remove(expenseItem.id);
          _pendingIds.remove(incomeItem.id);
          await _db.markSynced(expenseItem.id);
          await _db.markSynced(incomeItem.id);
          _retryPendingOperations();
        })
        .catchError((error) {
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
        })
        .catchError((error) {
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
        })
        .catchError((error) {
          debugPrint('Firestore updateTransaction error: $error');
        });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    _categorySubscription?.cancel();
    super.dispose();
  }
}
