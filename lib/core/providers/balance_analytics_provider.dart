import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';

class BalanceAnalyticsProvider extends ChangeNotifier {
  List<TransactionItem> _transactions = [];
  List<DebtItem> _debts = [];

  // ─── computed totals ────────────────────────────────────────────

  double allTimeCashBalance = 0.0;
  double allTimeBankBalance = 0.0;
  double allTimeTotalBalance = 0.0;

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
      cash += d.isReceive ? d.amount : -d.amount;
    }

    allTimeCashBalance = cash;
    allTimeBankBalance = bank;
    allTimeTotalBalance = cash + bank;
  }

  // ─── equality guards ────────────────────────────────────────────

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
          ai.isReceive != bi.isReceive) {
        return false;
      }
    }
    return true;
  }
}
