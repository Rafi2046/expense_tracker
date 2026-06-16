import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final double amount;
  final String category;
  final String note;
  final bool isIncome;
  final DateTime dateTime;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.isIncome,
    required this.dateTime,
  });
}

class TransactionProvider extends ChangeNotifier {
  final List<String> _expenseCategories = [];

  final List<String> _incomeCategories = [];

  final List<TransactionItem> _transactions = [];

  List<String> get expenseCategories => List.unmodifiable(_expenseCategories);
  List<String> get incomeCategories => List.unmodifiable(_incomeCategories);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

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
}
