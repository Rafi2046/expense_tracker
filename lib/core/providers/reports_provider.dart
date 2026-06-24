import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/model/unified_transaction.dart';
import 'package:expense_tracker/core/model/ledger_item.dart';
import 'package:expense_tracker/core/model/category_summary.dart';

class ReportsProvider extends ChangeNotifier {
  TransactionProvider? _txProvider;
  DebtProvider? _debtProvider;

  // Shared Date Range for all reports (defaults to current month)
  DateTimeRange? _selectedDateRange;

  // All Transactions filtering
  String _searchQuery = '';
  String _selectedType = 'All Transactions';
  String? _selectedPartyName;

  // Party Statement filtering
  String? _selectedPartyNameForStatement;

  ReportsProvider() {
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  void updateProviders(TransactionProvider tx, DebtProvider debt) {
    _txProvider = tx;
    _debtProvider = debt;
    notifyListeners();
  }

  // Getters
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String? get selectedPartyName => _selectedPartyName;
  String? get selectedPartyNameForStatement => _selectedPartyNameForStatement;

  // Setters/actions
  void setDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setAllTransactionsSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setAllTransactionsType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setAllTransactionsParty(String? partyName) {
    _selectedPartyName = partyName;
    notifyListeners();
  }

  void setStatementParty(String? partyName) {
    _selectedPartyNameForStatement = partyName;
    notifyListeners();
  }

  // 1. All Transactions Screen Calculations
  List<UnifiedTransaction> get filteredTransactions {
    if (_txProvider == null || _debtProvider == null) return [];

    final List<UnifiedTransaction> all = [];

    // Add Incomes & Expenses
    for (var tx in _txProvider!.transactions) {
      all.add(UnifiedTransaction(
        id: tx.id,
        title: tx.note.isNotEmpty ? tx.note : tx.category,
        subtitle: tx.category,
        amount: tx.amount,
        dateTime: tx.dateTime,
        type: tx.isIncome ? 'Income' : 'Expense',
        paymentMethod: tx.paymentMethod,
      ));
    }

    // Add Payments from debts
    for (var d in _debtProvider!.items) {
      all.add(UnifiedTransaction(
        id: d.id,
        title: d.name,
        subtitle: d.detail,
        amount: d.amount,
        dateTime: d.createdAt,
        type: d.isReceive ? 'Payment In' : 'Payment Out',
        partyName: d.name,
        paymentMethod: 'Cash',
      ));
    }

    // Sort by latest date first
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Filter
    return all.where((tx) {
      // Date filter
      if (_selectedDateRange != null) {
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
        if (tx.dateTime.isBefore(start) || tx.dateTime.isAfter(end)) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchTitle = tx.title.toLowerCase().contains(q);
        final matchSubtitle = tx.subtitle.toLowerCase().contains(q);
        final matchParty = tx.partyName?.toLowerCase().contains(q) ?? false;
        if (!matchTitle && !matchSubtitle && !matchParty) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != 'All Transactions') {
        if (tx.type != _selectedType) return false;
      }

      // Party filter
      if (_selectedPartyName != null) {
        if (tx.partyName != _selectedPartyName) return false;
      }

      return true;
    }).toList();
  }

  // All Transactions Screen Totals
  Map<String, double> get allTransactionsTotals {
    double totalPaymentsIn = 0.0;
    double totalPaymentsOut = 0.0;
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in filteredTransactions) {
      if (tx.type == 'Payment In') totalPaymentsIn += tx.amount;
      if (tx.type == 'Payment Out') totalPaymentsOut += tx.amount;
      if (tx.type == 'Income') totalIncome += tx.amount;
      if (tx.type == 'Expense') totalExpense += tx.amount;
    }

    return {
      'totalPaymentsIn': totalPaymentsIn,
      'totalPaymentsOut': totalPaymentsOut,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }

  // 2. Party Statement Calculations
  List<DebtItem> get partyStatementTransactions {
    if (_debtProvider == null || _selectedPartyNameForStatement == null) return [];

    final filtered = _debtProvider!.items.where((item) {
      if (item.name != _selectedPartyNameForStatement) return false;

      if (_selectedDateRange != null) {
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
        if (item.createdAt.isBefore(start) || item.createdAt.isAfter(end)) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Map<String, dynamic> get partyStatementTotals {
    double receiveTotal = 0.0;
    double giveTotal = 0.0;
    for (var tx in partyStatementTransactions) {
      if (tx.isReceive) {
        receiveTotal += tx.amount;
      } else {
        giveTotal += tx.amount;
      }
    }
    final netBalance = receiveTotal - giveTotal;
    return {
      'receiveTotal': receiveTotal,
      'giveTotal': giveTotal,
      'netBalance': netBalance,
    };
  }

  // 3. Bank Statement Calculations
  List<LedgerItem> get bankStatementTransactions {
    if (_txProvider == null) return [];

    final List<LedgerItem> ledger = [];

    for (var tx in _txProvider!.transactions) {
      if (tx.paymentMethod == 'Bank') {
        ledger.add(LedgerItem(
          id: tx.id,
          title: tx.isIncome ? 'Money In' : 'Money Out',
          subtitle: tx.note.isNotEmpty ? '${tx.note} (${tx.category})' : tx.category,
          amount: tx.amount,
          dateTime: tx.dateTime,
          isCredit: tx.isIncome,
        ));
      }
    }

    ledger.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    double runningBal = 0.0;
    for (var item in ledger) {
      if (item.isCredit) {
        runningBal += item.amount;
      } else {
        runningBal -= item.amount;
      }
      item.runningBalance = runningBal;
    }

    List<LedgerItem> filtered = [];
    if (_selectedDateRange != null) {
      final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
      final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);

      filtered = ledger.where((item) {
        return !item.dateTime.isBefore(start) && !item.dateTime.isAfter(end);
      }).toList();
    } else {
      filtered = List.from(ledger);
    }

    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return filtered;
  }

  double get bankClosingBalance {
    final transactions = bankStatementTransactions;
    if (transactions.isEmpty) return 0.0;
    return transactions.first.runningBalance;
  }

  // 4. Income Expense Calculations
  List<TransactionItem> get filteredIncomeExpenseTransactions {
    if (_txProvider == null) return [];

    if (_selectedDateRange != null) {
      final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
      final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);

      return _txProvider!.transactions.where((tx) {
        return !tx.dateTime.isBefore(start) && !tx.dateTime.isAfter(end);
      }).toList();
    }
    return List.from(_txProvider!.transactions);
  }

  Map<String, dynamic> get incomeExpenseData {
    final txs = filteredIncomeExpenseTransactions;
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final Map<String, List<TransactionItem>> grouped = {};

    for (var tx in txs) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
      grouped.putIfAbsent(tx.category, () => []).add(tx);
    }

    final netProfit = totalIncome - totalExpense;

    final List<CategorySummary> summaries = [];
    grouped.forEach((category, items) {
      double sum = 0.0;
      final isInc = items.first.isIncome;
      for (var item in items) {
        sum += item.amount;
      }
      summaries.add(CategorySummary(
        categoryName: category,
        totalAmount: sum,
        isIncome: isInc,
        transactionCount: items.length,
      ));
    });

    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    final incomeSummaries = summaries.where((s) => s.isIncome).toList();
    final expenseSummaries = summaries.where((s) => !s.isIncome).toList();

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netProfit': netProfit,
      'incomeSummaries': incomeSummaries,
      'expenseSummaries': expenseSummaries,
    };
  }
}
