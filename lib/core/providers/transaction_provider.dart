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
}

enum TransactionSortOption {
  latest,
  amountHighToLow,
  amountLowToHigh;
}

class TransactionProvider extends ChangeNotifier {
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

    // Seed mock data for the current month
    _transactions.addAll([
      TransactionItem(
        id: '1',
        amount: 50.0,
        category: 'Transport',
        note: 'Bus Rental',
        isIncome: false,
        dateTime: DateTime.now().subtract(const Duration(hours: 3)),
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: '2',
        amount: 500.0,
        category: 'Medicine',
        note: 'Medicine',
        isIncome: false,
        dateTime: DateTime.now().subtract(const Duration(hours: 6)),
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: '3',
        amount: 300.0,
        category: 'Online Shopping',
        note: 'Gadget Purchase',
        isIncome: false,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        paymentMethod: 'Bank',
      ),
      TransactionItem(
        id: '4',
        amount: 500.0,
        category: 'Income #1',
        note: 'Commission',
        isIncome: true,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'Cash',
      ),
    ]);
  }

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
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void transferBalance(double amount, String fromAccount, String toAccount) {
    final now = DateTime.now();
    final expenseItem = TransactionItem(
      id: '${now.millisecondsSinceEpoch}_1',
      amount: amount,
      category: 'Transfer',
      note: 'Transfer to $toAccount',
      isIncome: false,
      dateTime: now,
      paymentMethod: fromAccount,
    );
    
    final incomeItem = TransactionItem(
      id: '${now.millisecondsSinceEpoch}_2',
      amount: amount,
      category: 'Transfer',
      note: 'Transfer from $fromAccount',
      isIncome: true,
      dateTime: now,
      paymentMethod: toAccount,
    );
    
    _transactions.insert(0, expenseItem);
    _transactions.insert(0, incomeItem);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}

