import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final double amount;
  final String category;
  final String note;
  final bool isIncome;
  final DateTime dateTime;
  final String? incomeMonth;
  final String paymentMethod; // 'Cash' or 'Bank'

  TransactionItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.isIncome,
    required this.dateTime,
    this.incomeMonth,
    this.paymentMethod = 'Cash',
  });

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'category': category,
        'note': note,
        'isIncome': isIncome,
        'dateTime': dateTime.toIso8601String(),
        'incomeMonth': incomeMonth,
        'paymentMethod': paymentMethod,
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
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  final Set<String> _knownDocIds = {};

  bool _isLoading = true;

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

    // Listen to auth changes to load transactions from Firestore
    _authSubscription = _auth.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel();
      _knownDocIds.clear();
      if (user != null) {
        _startListening(user.uid);
      } else {
        _transactions.clear();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _startListening(String uid) {
    _isLoading = true;
    notifyListeners();

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
                _transactions.add(
                  TransactionItem.fromMap(docId, change.doc.data()!),
                );
              }
              break;
            case DocumentChangeType.modified:
              final index = _transactions.indexWhere((t) => t.id == docId);
              if (index != -1) {
                _transactions[index] =
                    TransactionItem.fromMap(docId, change.doc.data()!);
              }
              break;
            case DocumentChangeType.removed:
              _knownDocIds.remove(docId);
              _transactions.removeWhere((t) => t.id == docId);
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

    final uniqueTransaction = TransactionItem(
      id: docRef.id,
      amount: transaction.amount,
      category: transaction.category,
      note: transaction.note,
      isIncome: transaction.isIncome,
      dateTime: transaction.dateTime,
      incomeMonth: transaction.incomeMonth,
      paymentMethod: transaction.paymentMethod,
    );

    _knownDocIds.add(uniqueTransaction.id);
    _transactions.insert(0, uniqueTransaction);
    notifyListeners();

    docRef.set(uniqueTransaction.toMap()).catchError((error) {
      debugPrint('Firestore addTransaction error: $error');
      _knownDocIds.remove(uniqueTransaction.id);
      _transactions.removeWhere((t) => t.id == uniqueTransaction.id);
      notifyListeners();
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
    );

    final incomeItem = TransactionItem(
      id: txRef.doc().id,
      amount: amount,
      category: 'Transfer',
      note: 'Transfer from $fromAccount',
      isIncome: true,
      dateTime: now,
      paymentMethod: toAccount,
    );

    _knownDocIds.add(expenseItem.id);
    _knownDocIds.add(incomeItem.id);
    _transactions.insert(0, expenseItem);
    _transactions.insert(0, incomeItem);
    notifyListeners();

    final batch = _firestore.batch();
    batch.set(txRef.doc(expenseItem.id), expenseItem.toMap());
    batch.set(txRef.doc(incomeItem.id), incomeItem.toMap());
    batch.commit().catchError((error) {
      debugPrint('Firestore transferBalance error: $error');
      _knownDocIds.remove(expenseItem.id);
      _knownDocIds.remove(incomeItem.id);
      _transactions.removeWhere((t) => t.id == expenseItem.id);
      _transactions.removeWhere((t) => t.id == incomeItem.id);
      notifyListeners();
    });
  }

  void deleteTransaction(String id) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final removedItem = _transactions[index];

    _knownDocIds.remove(id);
    _transactions.removeAt(index);
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete()
        .catchError((error) {
      debugPrint('Firestore deleteTransaction error: $error');
      _knownDocIds.add(id);
      _transactions.insert(0, removedItem);
      notifyListeners();
    });
  }

  void updateTransaction(TransactionItem transaction) {
    final user = _auth.currentUser;
    if (user == null) return;

    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) return;

    final oldTransaction = _transactions[index];
    _transactions[index] = transaction;
    notifyListeners();

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap())
        .catchError((error) {
      debugPrint('Firestore updateTransaction error: $error');
      final currentIndex =
          _transactions.indexWhere((t) => t.id == transaction.id);
      if (currentIndex != -1) {
        _transactions[currentIndex] = oldTransaction;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}

