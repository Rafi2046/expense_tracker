import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/model/account_model.dart';

class BalanceAnalyticsProvider extends ChangeNotifier {
  List<TransactionItem> _transactions = [];
  List<DebtItem> _debts = [];

  String? _currentProfileId;
  StreamSubscription<User?>? _authSubscription;

  double allTimeCashBalance = 0.0;
  double allTimeBankBalance = 0.0;
  double allTimeTotalBalance = 0.0;
  Map<String, double> allAccountBalances = {};
  List<AccountModel> _accounts = [];

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
      allAccountBalances = {};
      _currentProfileId = null;
      notifyListeners();
    }
  }

  void updateData(
    List<TransactionItem> transactions,
    List<DebtItem> debts,
    List<AccountModel> accounts,
  ) {
    if (_isListEqual(transactions, _transactions) &&
        _isDebtListEqual(debts, _debts) &&
        _isAccountListEqual(accounts, _accounts)) {
      return;
    }

    _transactions = transactions;
    _debts = debts;
    _accounts = accounts;
    _recompute();
    notifyListeners();
  }

  void _recompute() {
    final Map<String, double> balances = {};

    // 1. Initialize balances with each account's initialBalance
    for (final acc in _accounts) {
      balances[acc.name] = acc.initialBalance;
    }

    // 2. Add/subtract transaction amounts
    for (final tx in _transactions) {
      final account = tx.paymentMethod;
      balances[account] = (balances[account] ?? 0.0) + (tx.isIncome ? tx.amount : -tx.amount);
    }

    // 3. Add/subtract debts (only affects Cash)
    for (final d in _debts) {
      if (d.isSettled) continue;
      balances['Cash'] = (balances['Cash'] ?? 0.0) + (d.isReceive ? d.amount : -d.amount);
    }

    allAccountBalances = Map.from(balances);
    allTimeCashBalance = balances['Cash'] ?? 0.0;
    allTimeBankBalance = balances['Bank'] ?? 0.0;
    allTimeTotalBalance = balances.values.fold(0.0, (sum, v) => sum + v);
  }

  double projectedBalance(String paymentMethod, {double? amount, bool? isIncome}) {
    double bal = 0.0;
    final accIdx = _accounts.indexWhere((a) => a.name == paymentMethod);
    if (accIdx != -1) {
      bal = _accounts[accIdx].initialBalance;
    }

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

  double getBalanceForAccount(String accountName) {
    return allAccountBalances[accountName] ?? 0.0;
  }

  void updateProfileId(String newProfileId) {
    if (_currentProfileId == newProfileId) return;
    _currentProfileId = newProfileId;
    _transactions = [];
    _debts = [];
    _accounts = [];
    allTimeCashBalance = 0.0;
    allTimeBankBalance = 0.0;
    allTimeTotalBalance = 0.0;
    allAccountBalances = {};
    notifyListeners();
  }

  void clear() {
    _transactions = [];
    _debts = [];
    allTimeCashBalance = 0.0;
    allTimeBankBalance = 0.0;
    allTimeTotalBalance = 0.0;
    allAccountBalances = {};
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

  bool _isAccountListEqual(List<AccountModel> a, List<AccountModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final ai = a[i], bi = b[i];
      if (ai.id != bi.id ||
          ai.name != bi.name ||
          ai.initialBalance != bi.initialBalance ||
          ai.profileId != bi.profileId) {
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
