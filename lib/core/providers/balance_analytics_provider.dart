import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';

class BalanceAnalyticsProvider extends ChangeNotifier {
  List<TransactionItem> _transactions = [];
  List<DebtItem> _debts = [];

  String? _currentProfileId;
  StreamSubscription<User?>? _authSubscription;

  double allTimeCashBalance = 0.0;
  double allTimeBankBalance = 0.0;
  double allTimeTotalBalance = 0.0;

  BalanceAnalyticsProvider() {
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    if (newUser == null) {
      _transactions = [];
      _debts = [];
      allTimeCashBalance = 0.0;
      allTimeBankBalance = 0.0;
      allTimeTotalBalance = 0.0;
      _currentProfileId = null;
      notifyListeners();
    }
  }

  void updateData(List<TransactionItem> transactions, List<DebtItem> debts) {
    if (_isListEqual(transactions, _transactions) && _isDebtListEqual(debts, _debts)) {
      return;
    }

    _transactions = transactions;
    _debts = debts;
    _recompute();
    notifyListeners();
  }

  void _recompute() {
    double cash = 0.0;
    double bank = 0.0;

    for (final tx in _transactions) {
      if (tx.paymentMethod == 'Cash') {
        cash += tx.isIncome ? tx.amount : -tx.amount;
      } else {
        bank += tx.isIncome ? tx.amount : -tx.amount;
      }
    }

    for (final d in _debts) {
      if (d.isSettled) continue;
      cash += d.isReceive ? d.amount : -d.amount;
    }

    allTimeCashBalance = cash;
    allTimeBankBalance = bank;
    allTimeTotalBalance = cash + bank;
  }

  double projectedBalance(String paymentMethod, {double? amount, bool? isIncome}) {
    double bal = 0.0;
    for (final tx in _transactions) {
      if (tx.paymentMethod == paymentMethod) {
        bal += tx.isIncome ? tx.amount : -tx.amount;
      }
    }
    if (paymentMethod == 'Cash') {
      for (final d in _debts) {
        bal += d.isReceive ? d.amount : -d.amount;
      }
    }
    if (amount != null) {
      bal += isIncome == true ? amount : -amount;
    }
    return bal;
  }

  void updateProfileId(String newProfileId) {
    if (_currentProfileId == newProfileId) return;
    _currentProfileId = newProfileId;
    _transactions = [];
    _debts = [];
    allTimeCashBalance = 0.0;
    allTimeBankBalance = 0.0;
    allTimeTotalBalance = 0.0;
    notifyListeners();
  }

  void clear() {
    _transactions = [];
    _debts = [];
    allTimeCashBalance = 0.0;
    allTimeBankBalance = 0.0;
    allTimeTotalBalance = 0.0;
    notifyListeners();
  }

  bool _isListEqual(List<TransactionItem> a, List<TransactionItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final ai = a[i], bi = b[i];
      if (ai.id != bi.id ||
          ai.amount != bi.amount ||
          ai.isIncome != bi.isIncome ||
          ai.paymentMethod != bi.paymentMethod) {
        return false;
      }
    }
    return true;
  }

  bool _isDebtListEqual(List<DebtItem> a, List<DebtItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final ai = a[i], bi = b[i];
      if (ai.id != bi.id ||
          ai.amount != bi.amount ||
          ai.isReceive != bi.isReceive ||
          ai.isSettled != bi.isSettled) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
