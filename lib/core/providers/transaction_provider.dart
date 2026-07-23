import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/services/notification_service.dart';
import 'package:expense_tracker/core/services/daily_summary_service.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/transaction_models.dart';
import '../utils/database_helper.dart';

export '../models/transaction_models.dart';

enum TransactionSortOption { latest, amountHighToLow, amountLowToHigh }

enum TransactionTypeFilter { all, income, expense }

enum TransactionPeriod { daily, monthly, yearly }

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  StreamSubscription<QuerySnapshot>? _categorySubscription;
  final Set<String> _knownDocIds = {};
  final Set<String> _pendingIds = {};
  final Set<String> _knownCategoryIds = {};
  final Set<String> _pendingCategoryIds = {};

  bool _isLoading = true;
  bool _isRetrying = false;

  String _activeProfileId;

  final List<CategoryItem> _categoryItems = [];
  final List<TransactionItem> _transactions = [];

  // Month, Search, and Sort states
  TransactionPeriod _selectedPeriod = TransactionPeriod.monthly;
  DateTime _selectedDate = DateTime.now();
  late final List<DateTime> availableMonths;
  int selectedMonthIndex = 6;
  bool isSearching = false;
  String searchQuery = '';
  TransactionSortOption sortOption = TransactionSortOption.latest;
  TransactionTypeFilter _transactionTypeFilter = TransactionTypeFilter.all;

  TransactionTypeFilter get transactionTypeFilter => _transactionTypeFilter;

  TransactionPeriod get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;

  void setSelectedPeriod(TransactionPeriod period) {
    _selectedPeriod = period;
    if (period == TransactionPeriod.daily) {
      _selectedDate = DateTime.now();
    } else if (period == TransactionPeriod.yearly) {
      _selectedDate = DateTime.now();
    } else {
      final month = availableMonths[selectedMonthIndex];
      _selectedDate = DateTime(month.year, month.month, _selectedDate.day).clampToMonthDays();
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    final idx = availableMonths.indexWhere((m) => m.year == date.year && m.month == date.month);
    if (idx != -1) {
      selectedMonthIndex = idx;
    }
    notifyListeners();
  }

  set transactionTypeFilter(TransactionTypeFilter value) {
    _transactionTypeFilter = value;
    notifyListeners();
  }

  TransactionProvider({required String initialProfileId})
      : _activeProfileId = initialProfileId {
    final now = DateTime.now();
    availableMonths = List.generate(12, (index) {
      return DateTime(now.year, now.month - 6 + index);
    });

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
      _categorySubscription?.cancel();
      _categorySubscription = null;
      _knownDocIds.clear();
      _pendingIds.clear();
      _knownCategoryIds.clear();
      _pendingCategoryIds.clear();
      _transactions.clear();
      _categoryItems.clear();
      _isLoading = true;
      notifyListeners();
      _db.clearUserData();
      return;
    }

    // userChanges() also fires on token refresh — do NOT tear down listeners
    // or re-addAll from SQLite (that doubles expenses and flips budget %).
    if (!uidChanged && previousUser != null && _firestoreSubscription != null) {
      return;
    }

    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _categorySubscription?.cancel();
    _categorySubscription = null;

    // Serialize wipe → reload so budget/expense reads never race the delete.
    () async {
      if (uidChanged) {
        _knownDocIds.clear();
        _pendingIds.clear();
        _knownCategoryIds.clear();
        _pendingCategoryIds.clear();
        _transactions.clear();
        _categoryItems.clear();
        _isLoading = true;
        notifyListeners();
        await _db.clearUserData();
      }
      await _startListening(newUser.uid);
    }();
  }

  Future<void> _startListening(String uid) async {
    _isLoading = true;
    notifyListeners();

    // Always replace in-memory lists — never addAll on top of existing rows.
    _transactions.clear();
    _categoryItems.clear();
    _knownDocIds.clear();
    _pendingIds.clear();
    _knownCategoryIds.clear();
    _pendingCategoryIds.clear();

    await _loadFromDatabase();
    await _loadCategoriesFromDatabase();
    _retryPendingOperations();
    _attachTransactionListener(uid);
    _attachCategoryListener(uid);
  }

  /// Re-hydrate SQLite + Firestore for the current profile (pull-to-refresh).
  Future<void> forceReload() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _categorySubscription?.cancel();
    _categorySubscription = null;
    await _startListening(uid);
  }

  void _attachTransactionListener(String uid) {
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
                  if (!_knownDocIds.contains(docId) && !_transactions.any((t) => t.id == docId)) {
                    _knownDocIds.add(docId);
                    final item = TransactionItem.fromMap(
                      docId,
                      change.doc.data()!,
                    );
                    _db.insertTransaction(item, syncStatus: 'synced', profileId: item.profileId);
                    if (item.profileId == _activeProfileId) {
                      _transactions.add(item);
                    }
                  }
                  break;
                case DocumentChangeType.modified:
                  if (!_pendingIds.contains(docId)) {
                    final item = TransactionItem.fromMap(
                      docId,
                      change.doc.data()!,
                    );
                    _db.updateTransaction(
                      item,
                      syncStatus: 'synced',
                      profileId: item.profileId,
                    );
                    final index = _transactions.indexWhere(
                      (t) => t.id == docId,
                    );
                    if (item.profileId == _activeProfileId) {
                      if (index != -1) {
                        _transactions[index] = item;
                      } else {
                        _transactions.add(item);
                      }
                    } else if (index != -1) {
                      _transactions.removeAt(index);
                    }
                  }
                  break;
                case DocumentChangeType.removed:
                  _knownDocIds.remove(docId);
                  _pendingIds.remove(docId);
                  _transactions.removeWhere((t) => t.id == docId);
                  _db.hardDeleteTransaction(docId, profileId: _activeProfileId);
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

  void _attachCategoryListener(String uid) {
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
                    _db.insertCategory(item, syncStatus: 'synced', profileId: item.profileId);
                    if (item.profileId == _activeProfileId) {
                      _categoryItems.add(item);
                    }
                  }
                  break;
                case DocumentChangeType.removed:
                  _knownCategoryIds.remove(docId);
                  _pendingCategoryIds.remove(docId);
                  _categoryItems.removeWhere((c) => c.id == docId);
                  _db.hardDeleteCategory(docId, profileId: _activeProfileId);
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
      final items = await _db.readAllTransactions(profileId: _activeProfileId);
      _transactions.addAll(items);
      for (final item in items) {
        _knownDocIds.add(item.id);
      }
      final pendingIds = await _db.readAllPendingIds(profileId: _activeProfileId);
      _pendingIds.addAll(pendingIds);
    } catch (e) {
      debugPrint('Error loading transactions from database: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  List<CategoryItem> _getDefaultCategories() {
    return [
      // Expense Categories
      CategoryItem(
        id: 'cat_food_$_activeProfileId',
        name: 'Food',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_transport_$_activeProfileId',
        name: 'Transport',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_medicine_$_activeProfileId',
        name: 'Medicine',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_rent_$_activeProfileId',
        name: 'Rent',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_entertainment_$_activeProfileId',
        name: 'Entertainment',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_shopping_$_activeProfileId',
        name: 'Shopping',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_utilities_$_activeProfileId',
        name: 'Utilities',
        isIncome: false,
        profileId: _activeProfileId,
      ),
      // Income Categories
      CategoryItem(
        id: 'cat_salary_$_activeProfileId',
        name: 'Salary',
        isIncome: true,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_freelance_$_activeProfileId',
        name: 'Freelance',
        isIncome: true,
        profileId: _activeProfileId,
      ),
      CategoryItem(
        id: 'cat_investment_$_activeProfileId',
        name: 'Investment',
        isIncome: true,
        profileId: _activeProfileId,
      ),
    ];
  }

  Future<void> _loadCategoriesFromDatabase() async {
    try {
      final items = await _db.readAllCategories(profileId: _activeProfileId);
      if (items.isEmpty) {
        final defaultCats = _getDefaultCategories();
        for (final cat in defaultCats) {
          await _db.insertCategory(cat, syncStatus: 'pending_create', profileId: _activeProfileId);
          _categoryItems.add(cat);
          _knownCategoryIds.add(cat.id);
          
          final uid = _firebaseUser?.uid;
          if (uid != null) {
            _firestore
                .collection('users')
                .doc(uid)
                .collection('categories')
                .doc(cat.id)
                .set(cat.toMap())
                .catchError((_) {});
          }
        }
      } else {
        _categoryItems.addAll(items);
        for (final item in items) {
          _knownCategoryIds.add(item.id);
        }
      }
      final pendingIds = await _db.readAllPendingCategoryIds(profileId: _activeProfileId);
      _pendingCategoryIds.addAll(pendingIds);
    } catch (e) {
      debugPrint('Error loading categories from database: $e');
    }
  }

  Future<void> _retryPendingOperations() async {
    if (_isRetrying) return;
    _isRetrying = true;
    try {
      final uid = _firebaseUser?.uid;
      if (uid == null) return;

      final pending = await _db.readPendingSyncs(profileId: _activeProfileId);
      for (final item in pending) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(item.id)
            .set(item.toMap())
            .then((_) {
              _db.markSynced(item.id, profileId: _activeProfileId);
              _pendingIds.remove(item.id);
            })
            .catchError((_) {});
      }

      final deleteIds = await _db.readPendingDeleteIds(profileId: _activeProfileId);
      for (final id in deleteIds) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(id)
            .delete()
            .then((_) {
              _db.hardDeleteTransaction(id, profileId: _activeProfileId);
              _pendingIds.remove(id);
            })
            .catchError((_) {});
      }

      final pendingCategories = await _db.readPendingCategorySyncs(profileId: _activeProfileId);
      for (final item in pendingCategories) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('categories')
            .doc(item.id)
            .set(item.toMap())
            .then((_) {
              _db.markCategorySynced(item.id, profileId: _activeProfileId);
              _pendingCategoryIds.remove(item.id);
            })
            .catchError((_) {});
      }

      final deleteCategoryIds = await _db.readPendingCategoryDeleteIds(profileId: _activeProfileId);
      for (final id in deleteCategoryIds) {
        _firestore
            .collection('users')
            .doc(uid)
            .collection('categories')
            .doc(id)
            .delete()
            .then((_) {
              _db.hardDeleteCategory(id, profileId: _activeProfileId);
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

  String get activeProfileId => _activeProfileId;

  bool get isLoading => _isLoading;

  List<String> get expenseCategories => List.unmodifiable(
    _categoryItems.where((c) => !c.isIncome).map((c) => c.name).toSet(),
  );

  List<String> get incomeCategories => List.unmodifiable(
    _categoryItems.where((c) => c.isIncome).map((c) => c.name).toSet(),
  );

  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  DateTime get selectedMonth => availableMonths[selectedMonthIndex];

  List<TransactionItem> get monthlyTransactions {
    final month = selectedMonth;
    return _transactions.where((tx) {
      return tx.dateTime.year == month.year && tx.dateTime.month == month.month;
    }).toList();
  }

  List<TransactionItem> get periodTransactions {
    return _transactions.where((tx) {
      if (_selectedPeriod == TransactionPeriod.daily) {
        return tx.dateTime.year == _selectedDate.year &&
            tx.dateTime.month == _selectedDate.month &&
            tx.dateTime.day == _selectedDate.day;
      } else if (_selectedPeriod == TransactionPeriod.yearly) {
        return tx.dateTime.year == _selectedDate.year;
      } else {
        // monthly
        return tx.dateTime.year == _selectedDate.year &&
            tx.dateTime.month == _selectedDate.month;
      }
    }).toList();
  }

  List<TransactionItem> get filteredTransactions {
    final periodTrans = periodTransactions;
    List<TransactionItem> results;
    if (!isSearching || searchQuery.trim().isEmpty) {
      results = List.from(periodTrans);
    } else {
      final query = searchQuery.toLowerCase().trim();
      results = periodTrans.where((tx) {
        return tx.note.toLowerCase().contains(query) ||
            tx.category.toLowerCase().contains(query);
      }).toList();
    }

    if (_transactionTypeFilter == TransactionTypeFilter.income) {
      results = results.where((tx) => tx.isIncome).toList();
    } else if (_transactionTypeFilter == TransactionTypeFilter.expense) {
      results = results.where((tx) => !tx.isIncome).toList();
    }

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

  double get monthlyIncome {
    return monthlyTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (total, tx) => total + tx.amount);
  }

  double get monthlyExpense {
    return monthlyTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (total, tx) => total + tx.amount);
  }

  double get monthlyNetBalance => monthlyIncome - monthlyExpense;

  double get periodIncome {
    return periodTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (total, tx) => total + tx.amount);
  }

  double get periodExpense {
    return periodTransactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (total, tx) => total + tx.amount);
  }

  double get periodNetBalance => periodIncome - periodExpense;

  // ─── Analytics Getters ─────────────────────────────────────────

  Map<String, double> get categoryExpenseBreakdown {
    final Map<String, double> breakdown = {};
    final Map<String, String> normalizedKeys = {};
    for (final tx in monthlyTransactions.where((t) => !t.isIncome)) {
      final normalized = tx.category.toLowerCase();
      normalizedKeys.putIfAbsent(normalized, () => tx.category);
      breakdown.update(
        normalized,
        (v) => v + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }
    return {for (final k in breakdown.keys) normalizedKeys[k]!: breakdown[k]!};
  }

  List<TransactionItem> get previousMonthTransactions {
    final current = selectedMonth;
    final prevYear = current.month == 1 ? current.year - 1 : current.year;
    final prevMonth = current.month == 1 ? 12 : current.month - 1;
    final result = _transactions
        .where((tx) =>
            tx.dateTime.year == prevYear && tx.dateTime.month == prevMonth)
        .toList();
    debugPrint(
        'DEBUG MoM [prevMonthTxns]: prev=$prevMonth/$prevYear, count=${result.length}');
    for (final tx in result) {
      debugPrint(
          '  tx: id=${tx.id}, amt=${tx.amount}, isIncome=${tx.isIncome}, date=${tx.dateTime}');
    }
    return result;
  }

  double get previousMonthExpense {
    double sum = 0;
    for (final tx in _transactions) {
      if (tx.dateTime.year == _prevYear &&
          tx.dateTime.month == _prevMonth &&
          !tx.isIncome) {
        sum += tx.amount;
      }
    }
    debugPrint(
        'DEBUG MoM [prevExpense]: prev=$_prevMonth/$_prevYear, sum=$sum');
    return sum;
  }

  double get previousMonthIncome {
    double sum = 0;
    for (final tx in _transactions) {
      if (tx.dateTime.year == _prevYear &&
          tx.dateTime.month == _prevMonth &&
          tx.isIncome) {
        sum += tx.amount;
      }
    }
    debugPrint(
        'DEBUG MoM [prevIncome]: prev=$_prevMonth/$_prevYear, sum=$sum');
    return sum;
  }

  int get _prevYear =>
      selectedMonth.month == 1 ? selectedMonth.year - 1 : selectedMonth.year;
  int get _prevMonth =>
      selectedMonth.month == 1 ? 12 : selectedMonth.month - 1;

  double get expenseChangePercent {
    final prev = previousMonthExpense;
    final curr = monthlyExpense;
    debugPrint(
        'DEBUG MoM [expense%]: prev=$prev, curr=$curr, result=${prev == 0 ? (curr > 0 ? 100 : 0) : ((curr - prev) / prev) * 100}');
    if (prev == 0) return curr > 0 ? 100 : 0;
    return ((curr - prev) / prev) * 100;
  }

  bool get isExpenseTrendGood => expenseChangePercent <= 0;

  String get expenseTrendDisplay {
    final prefix = expenseChangePercent >= 0 ? '+' : '';
    return '$prefix${expenseChangePercent.toStringAsFixed(1)}%';
  }

  double get incomeChangePercent {
    final prev = previousMonthIncome;
    final curr = monthlyIncome;
    debugPrint(
        'DEBUG MoM [income%]: prev=$prev, curr=$curr, result=${prev == 0 ? (curr > 0 ? 100 : 0) : ((curr - prev) / prev) * 100}');
    if (prev == 0) return curr > 0 ? 100 : 0;
    return ((curr - prev) / prev) * 100;
  }

  bool get isIncomeTrendGood => incomeChangePercent >= 0;

  String get incomeTrendDisplay {
    final prefix = incomeChangePercent >= 0 ? '+' : '';
    return '$prefix${incomeChangePercent.toStringAsFixed(1)}%';
  }

  // ─── Calendar-Anchored Getters ────────────────────────────────

  List<TransactionItem> get _calendarCurrentTransactions {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.dateTime.year == now.year && tx.dateTime.month == now.month)
        .toList();
  }

  List<TransactionItem> get _calendarPreviousTransactions {
    final now = DateTime.now();
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    return _transactions
        .where((tx) =>
            tx.dateTime.year == prevYear && tx.dateTime.month == prevMonth)
        .toList();
  }

  double get calendarMonthIncome =>
      _calendarCurrentTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (s, t) => s + t.amount);

  double get calendarMonthExpense =>
      _calendarCurrentTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (s, t) => s + t.amount);

  double get calendarPrevMonthIncome =>
      _calendarPreviousTransactions
          .where((tx) => tx.isIncome)
          .fold(0.0, (s, t) => s + t.amount);

  double get calendarPrevMonthExpense =>
      _calendarPreviousTransactions
          .where((tx) => !tx.isIncome)
          .fold(0.0, (s, t) => s + t.amount);

  double get calendarExpenseChangePercent {
    final prev = calendarPrevMonthExpense;
    if (prev == 0) return calendarMonthExpense > 0 ? 100 : 0;
    return ((calendarMonthExpense - prev) / prev) * 100;
  }

  bool get isCalendarExpenseTrendGood => calendarExpenseChangePercent <= 0;

  String get calendarExpenseTrendDisplay {
    final pct = calendarExpenseChangePercent;
    final prefix = pct >= 0 ? '+' : '';
    return '$prefix${pct.toStringAsFixed(1)}%';
  }

  double get calendarIncomeChangePercent {
    final prev = calendarPrevMonthIncome;
    if (prev == 0) return calendarMonthIncome > 0 ? 100 : 0;
    return ((calendarMonthIncome - prev) / prev) * 100;
  }

  bool get isCalendarIncomeTrendGood => calendarIncomeChangePercent >= 0;

  String get calendarIncomeTrendDisplay {
    final pct = calendarIncomeChangePercent;
    final prefix = pct >= 0 ? '+' : '';
    return '$prefix${pct.toStringAsFixed(1)}%';
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

  // ─── Public API ───────────────────────────────────────────────

  void clear() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _categorySubscription?.cancel();
    _categorySubscription = null;
    _knownDocIds.clear();
    _pendingIds.clear();
    _knownCategoryIds.clear();
    _pendingCategoryIds.clear();
    _transactions.clear();
    _categoryItems.clear();
    _isLoading = true;
    _firebaseUser = null;
    notifyListeners();
  }

  void selectMonthIndex(int index) {
    if (index >= 0 && index < availableMonths.length) {
      selectedMonthIndex = index;
      final month = availableMonths[index];
      _selectedDate = DateTime(month.year, month.month, _selectedDate.day).clampToMonthDays();
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

  bool addExpenseCategory(String category) {
    final cleanCategory = category.trim();
    if (cleanCategory.isEmpty) return false;
    if (_categoryItems.any(
      (c) => c.name.toLowerCase() == cleanCategory.toLowerCase() && !c.isIncome,
    )) {
      return false;
    }

    final user = _firebaseUser;
    final String docId;
    DocumentReference? docRef;
    if (user != null) {
      docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc();
      docId = docRef.id;
    } else {
      docId = DateTime.now().microsecondsSinceEpoch.toString();
    }

    final now = DateTime.now();
    final item = CategoryItem(
      id: docId,
      name: cleanCategory,
      isIncome: false,
      lastModified: now,
      profileId: _activeProfileId,
    );

    _db.insertCategory(item, syncStatus: user != null ? 'pending_create' : 'synced', profileId: _activeProfileId);
    _knownCategoryIds.add(item.id);
    if (user != null) {
      _pendingCategoryIds.add(item.id);
    }
    _categoryItems.add(item);
    notifyListeners();

    if (docRef != null) {
      docRef
          .set(item.toMap())
          .then((_) async {
            _pendingCategoryIds.remove(item.id);
            await _db.markCategorySynced(item.id, profileId: _activeProfileId);
            _retryPendingOperations();
          })
          .catchError((error) {
            debugPrint('Firestore addExpenseCategory error: $error');
          });
    }
    return true;
  }

  void deleteExpenseCategory(String category) {
    final idx = _categoryItems.indexWhere(
      (c) => c.name == category && !c.isIncome,
    );
    if (idx == -1) return;

    final item = _categoryItems[idx];

    _db.softDeleteCategory(item.id, profileId: _activeProfileId);
    _knownCategoryIds.remove(item.id);
    _categoryItems.removeAt(idx);
    notifyListeners();

    final user = _firebaseUser;
    if (user != null) {
      _pendingCategoryIds.add(item.id);
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(item.id)
          .delete()
          .then((_) async {
            _pendingCategoryIds.remove(item.id);
            await _db.hardDeleteCategory(item.id, profileId: _activeProfileId);
            _retryPendingOperations();
          })
          .catchError((error) {
            debugPrint('Firestore deleteExpenseCategory error: $error');
          });
    }
  }

  bool addIncomeCategory(String category) {
    final cleanCategory = category.trim();
    if (cleanCategory.isEmpty) return false;
    if (_categoryItems.any(
      (c) => c.name.toLowerCase() == cleanCategory.toLowerCase() && c.isIncome,
    )) {
      return false;
    }

    final user = _firebaseUser;
    final String docId;
    DocumentReference? docRef;
    if (user != null) {
      docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc();
      docId = docRef.id;
    } else {
      docId = DateTime.now().microsecondsSinceEpoch.toString();
    }

    final now = DateTime.now();
    final item = CategoryItem(
      id: docId,
      name: cleanCategory,
      isIncome: true,
      lastModified: now,
      profileId: _activeProfileId,
    );

    _db.insertCategory(item, syncStatus: user != null ? 'pending_create' : 'synced', profileId: _activeProfileId);
    _knownCategoryIds.add(item.id);
    if (user != null) {
      _pendingCategoryIds.add(item.id);
    }
    _categoryItems.add(item);
    notifyListeners();

    if (docRef != null) {
      docRef
          .set(item.toMap())
          .then((_) async {
            _pendingCategoryIds.remove(item.id);
            await _db.markCategorySynced(item.id, profileId: _activeProfileId);
            _retryPendingOperations();
          })
          .catchError((error) {
            debugPrint('Firestore addIncomeCategory error: $error');
          });
    }
    return true;
  }

  void deleteIncomeCategory(String category) {
    final idx = _categoryItems.indexWhere(
      (c) => c.name == category && c.isIncome,
    );
    if (idx == -1) return;

    final item = _categoryItems[idx];

    _db.softDeleteCategory(item.id, profileId: _activeProfileId);
    _knownCategoryIds.remove(item.id);
    _categoryItems.removeAt(idx);
    notifyListeners();

    final user = _firebaseUser;
    if (user != null) {
      _pendingCategoryIds.add(item.id);
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(item.id)
          .delete()
          .then((_) async {
            _pendingCategoryIds.remove(item.id);
            await _db.hardDeleteCategory(item.id, profileId: _activeProfileId);
            _retryPendingOperations();
          })
          .catchError((error) {
            debugPrint('Firestore deleteIncomeCategory error: $error');
          });
    }
  }

  void renameCategory(
    String oldName,
    String newName, {
    required bool isIncome,
  }) {
    final cleanNewName = newName.trim();
    if (cleanNewName.isEmpty) return;
    if (oldName.trim().toLowerCase() == cleanNewName.toLowerCase()) return;

    _db.renameCategory(oldName, cleanNewName, isIncome: isIncome, profileId: _activeProfileId);

    CategoryItem? renamedCategory;
    for (int i = 0; i < _categoryItems.length; i++) {
      if (_categoryItems[i].name == oldName &&
          _categoryItems[i].isIncome == isIncome) {
        renamedCategory = CategoryItem(
          id: _categoryItems[i].id,
          name: cleanNewName,
          isIncome: _categoryItems[i].isIncome,
          lastModified: DateTime.now(),
          profileId: _activeProfileId,
        );
        _categoryItems[i] = renamedCategory;
        _pendingCategoryIds.add(renamedCategory.id);
        break;
      }
    }

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
          profileId: _activeProfileId,
        );
        _transactions[i] = updated;
        _pendingIds.add(updated.id);
        affectedTxIds.add(updated.id);
      }
    }
    notifyListeners();

    final user = _firebaseUser;
    if (user != null) {
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

      batch
          .commit()
          .then((_) async {
            if (renamedCategory != null) {
              _pendingCategoryIds.remove(renamedCategory.id);
              await _db.markCategorySynced(renamedCategory.id, profileId: _activeProfileId);
            }
            for (final id in affectedTxIds) {
              _pendingIds.remove(id);
              await _db.markSynced(id, profileId: _activeProfileId);
            }
            _retryPendingOperations();
          })
          .catchError((error) {
            debugPrint('Firestore renameCategory batch error: $error');
          });
    }
  }

  void addTransaction(TransactionItem transaction) {
    debugPrint('DIAG PROVIDER ENTER: transaction.dateTime=${transaction.dateTime} month=${transaction.dateTime.month} day=${transaction.dateTime.day}');
    final user = _firebaseUser;
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
      profileId: _activeProfileId,
      partyName: transaction.partyName,
    );

    _db.insertTransaction(uniqueTransaction, syncStatus: 'pending_create', profileId: _activeProfileId);

    _knownDocIds.add(uniqueTransaction.id);
    _pendingIds.add(uniqueTransaction.id);
    debugPrint('DIAG PROVIDER STORE: uniqueTransaction.dateTime=${uniqueTransaction.dateTime} month=${uniqueTransaction.dateTime.month}');
    _transactions.insert(0, uniqueTransaction);
    notifyListeners();
    NotificationService.instance.cancelEodReminderForToday();
    DailySummaryService.updateDailyNotification(profileId: _activeProfileId);

    // Budget threshold check (only for expenses)
    if (!uniqueTransaction.isIncome) {
      checkBudgetThreshold();
    }

    docRef
        .set(uniqueTransaction.toMap())
        .then((_) async {
          _pendingIds.remove(uniqueTransaction.id);
          await _db.markSynced(uniqueTransaction.id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore addTransaction error: $error');
        });
  }

  /// Checks if the current month's expense has crossed budget thresholds
  /// and fires a notification if so.
  Future<void> checkBudgetThreshold() async {
    try {
      final budgetAmount = await _db.readBudget(profileId: _activeProfileId);
      if (budgetAmount == null || budgetAmount <= 0) return;

      final currentExpense = monthlyExpense;

      // Read currency code from SharedPrefs, resolve symbol
      const symbols = {
        'BDT': '\u09F3', 'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3',
        'INR': '\u20B9', 'JPY': '\u00A5', 'AED': '\u062F.\u0625', 'CAD': r'$',
      };
      final currencyCode = SharedPrefsHelper.getString('selected_currency_code') ?? 'BDT';
      final currencySymbol = symbols[currencyCode] ?? r'$';

      final result = await NotificationService.instance.checkBudgetThreshold(
        budgetAmount: budgetAmount,
        currentMonthExpense: currentExpense,
        currencySymbol: currencySymbol,
        profileId: _activeProfileId,
      );

      if (result != null) {
        await _db.insertInAppNotification(
          id: 'budget_notif_${DateTime.now().millisecondsSinceEpoch}',
          title: result.titleKey,
          body: result.bodyKey,
          type: 'alert',
          profileId: _activeProfileId,
          args: result.args,
        );
        NotificationProvider.notifyDataChanged();
      }
    } catch (e) {
      debugPrint('TransactionProvider._checkBudgetThreshold error: $e');
    }
  }

  void transferBalance(double amount, String fromAccount, String toAccount) {
    final user = _firebaseUser;
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
      profileId: _activeProfileId,
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
      profileId: _activeProfileId,
    );

    _db.insertTransaction(expenseItem, syncStatus: 'pending_create', profileId: _activeProfileId);
    _db.insertTransaction(incomeItem, syncStatus: 'pending_create', profileId: _activeProfileId);

    _knownDocIds.add(expenseItem.id);
    _knownDocIds.add(incomeItem.id);
    _pendingIds.add(expenseItem.id);
    _pendingIds.add(incomeItem.id);
    _transactions.insert(0, expenseItem);
    _transactions.insert(0, incomeItem);
    notifyListeners();
    NotificationService.instance.cancelEodReminderForToday();

    final batch = _firestore.batch();
    batch.set(txRef.doc(expenseItem.id), expenseItem.toMap());
    batch.set(txRef.doc(incomeItem.id), incomeItem.toMap());
    batch
        .commit()
        .then((_) async {
          _pendingIds.remove(expenseItem.id);
          _pendingIds.remove(incomeItem.id);
          await _db.markSynced(expenseItem.id, profileId: _activeProfileId);
          await _db.markSynced(incomeItem.id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore transferBalance error: $error');
        });
  }

  void deleteTransaction(String id) {
    final user = _firebaseUser;
    if (user == null) return;

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    _db.softDeleteTransaction(id, profileId: _activeProfileId);

    _knownDocIds.remove(id);
    _pendingIds.add(id);
    _transactions.removeAt(index);
    notifyListeners();
    DailySummaryService.updateDailyNotification(profileId: _activeProfileId);

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete()
        .then((_) async {
          _pendingIds.remove(id);
          await _db.hardDeleteTransaction(id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore deleteTransaction error: $error');
        });
  }

  void updateTransaction(TransactionItem transaction) {
    final user = _firebaseUser;
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
      profileId: _activeProfileId,
      partyName: transaction.partyName,
    );

    _db.updateTransaction(updated, syncStatus: 'pending_update', profileId: _activeProfileId);

    _pendingIds.add(updated.id);
    _transactions[index] = updated;
    notifyListeners();
    DailySummaryService.updateDailyNotification(profileId: _activeProfileId);

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(updated.id)
        .update(updated.toMap())
        .then((_) async {
          _pendingIds.remove(updated.id);
          await _db.markSynced(updated.id, profileId: _activeProfileId);
          _retryPendingOperations();
        })
        .catchError((error) {
          debugPrint('Firestore updateTransaction error: $error');
        });
  }

  Future<void> reloadFromDatabase() async {
    _transactions.clear();
    _pendingIds.clear();
    await _loadFromDatabase();
  }

  Future<void> reloadCategoriesFromDatabase() async {
    _categoryItems.clear();
    _pendingCategoryIds.clear();
    await _loadCategoriesFromDatabase();
  }

  void updateProfileId(String id) {
    if (id == _activeProfileId) return;
    debugPrint('TransactionProvider.updateProfileId: switching to $id');
    _activeProfileId = id;
    _firestoreSubscription?.cancel();
    _categorySubscription?.cancel();
    _knownDocIds.clear();
    _pendingIds.clear();
    _knownCategoryIds.clear();
    _pendingCategoryIds.clear();
    _transactions.clear();
    _categoryItems.clear();
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
    _categorySubscription?.cancel();
    super.dispose();
  }
}

extension DateTimeClamping on DateTime {
  DateTime clampToMonthDays() {
    final nextMonthStart = DateTime(year, month + 1, 1);
    final lastDay = nextMonthStart.subtract(const Duration(days: 1)).day;
    final clampedDay = day.clamp(1, lastDay);
    return DateTime(year, month, clampedDay, hour, minute, second, millisecond, microsecond);
  }
}
