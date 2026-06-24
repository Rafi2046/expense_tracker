import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/model/unified_transaction.dart';
import 'package:expense_tracker/core/model/ledger_item.dart';
import 'package:expense_tracker/core/model/category_summary.dart';
import 'package:expense_tracker/core/model/party_report_summary.dart';

enum ReportSortOption {
  latest,
  oldest,
  amountHighToLow,
  amountLowToHigh,
}

enum DateRangeOption {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  thisFiscalYear,
  thisYear,
  allTime,
  custom,
}

enum PartyStatementViewMode {
  card,
  table,
}

class ReportsProvider extends ChangeNotifier {
  TransactionProvider? _txProvider;
  DebtProvider? _debtProvider;

  // Shared Date Range for all reports (defaults to current month)
  DateTimeRange? _selectedDateRange;
  DateRangeOption _selectedOption = DateRangeOption.thisMonth;

  // All Transactions filtering & sorting
  String _searchQuery = '';
  String _selectedType = 'All Transactions';
  String? _selectedPartyName;
  ReportSortOption _sortOption = ReportSortOption.latest;

  // Party Statement filtering
  String? _selectedPartyNameForStatement;

  // Parties Report filtering
  String _partiesSearchQuery = '';

  // Party Statement view mode
  PartyStatementViewMode _partyStatementViewMode = PartyStatementViewMode.card;

  ReportsProvider() {
    _selectedDateRange = getDateTimeRangeForOption(DateRangeOption.thisMonth);
  }

  void updateProviders(TransactionProvider tx, DebtProvider debt) {
    _txProvider = tx;
    _debtProvider = debt;
    notifyListeners();
  }

  // Getters
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  DateRangeOption get selectedOption => _selectedOption;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String? get selectedPartyName => _selectedPartyName;
  String? get selectedPartyNameForStatement => _selectedPartyNameForStatement;
  ReportSortOption get sortOption => _sortOption;
  String get partiesSearchQuery => _partiesSearchQuery;
  PartyStatementViewMode get partyStatementViewMode => _partyStatementViewMode;

  // Setters/actions
  void setDateRange(DateTimeRange? range, {DateRangeOption option = DateRangeOption.custom}) {
    _selectedDateRange = range;
    _selectedOption = option;
    notifyListeners();
  }

  void setDateRangeOption(DateRangeOption option, {DateTimeRange? customRange}) {
    _selectedOption = option;
    if (option == DateRangeOption.custom && customRange != null) {
      _selectedDateRange = customRange;
    } else {
      _selectedDateRange = getDateTimeRangeForOption(option);
    }
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

  void setSortOption(ReportSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setPartiesSearch(String query) {
    _partiesSearchQuery = query;
    notifyListeners();
  }

  void setPartyStatementViewMode(PartyStatementViewMode mode) {
    _partyStatementViewMode = mode;
    notifyListeners();
  }

  // Helper: Get DateTimeRange for an option
  DateTimeRange? getDateTimeRangeForOption(DateRangeOption option) {
    final now = DateTime.now();
    switch (option) {
      case DateRangeOption.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day),
        );
      case DateRangeOption.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(yesterday.year, yesterday.month, yesterday.day),
          end: DateTime(yesterday.year, yesterday.month, yesterday.day),
        );
      case DateRangeOption.thisWeek:
        // Sunday of current week
        final sunday = now.subtract(Duration(days: now.weekday % 7));
        final saturday = sunday.add(const Duration(days: 6));
        return DateTimeRange(
          start: DateTime(sunday.year, sunday.month, sunday.day),
          end: DateTime(saturday.year, saturday.month, saturday.day),
        );
      case DateRangeOption.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case DateRangeOption.lastMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
      case DateRangeOption.thisFiscalYear:
        // Bangladesh/India: July 1 to June 30
        int startYear = now.month >= 7 ? now.year : now.year - 1;
        return DateTimeRange(
          start: DateTime(startYear, 7, 1),
          end: DateTime(startYear + 1, 6, 30),
        );
      case DateRangeOption.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      case DateRangeOption.allTime:
        return null;
      case DateRangeOption.custom:
        return _selectedDateRange;
    }
  }

  // Helper: Get Title string for Option
  String getDateRangeOptionTitle(DateRangeOption option) {
    switch (option) {
      case DateRangeOption.today:
        return 'Today';
      case DateRangeOption.yesterday:
        return 'Yesterday';
      case DateRangeOption.thisWeek:
        return 'This Week';
      case DateRangeOption.thisMonth:
        return 'This Month';
      case DateRangeOption.lastMonth:
        return 'Last Month';
      case DateRangeOption.thisFiscalYear:
        return 'This Fiscal Year';
      case DateRangeOption.thisYear:
        return 'This Year';
      case DateRangeOption.allTime:
        return 'All Time';
      case DateRangeOption.custom:
        return 'Custom Date';
    }
  }

  // Helper: Get Formatted Subtitle for Option
  String getDateRangeSubtitle(DateRangeOption option, DateTimeRange? range) {
    if (option == DateRangeOption.allTime) {
      return 'See Transactions of all time';
    }
    if (option == DateRangeOption.custom && range == null) {
      return 'Select date from calendar';
    }
    final targetRange = range ?? getDateTimeRangeForOption(option);
    if (targetRange == null) return 'Select range';

    final DateFormat formatter = DateFormat('dd MMM yyyy');
    if (option == DateRangeOption.today || option == DateRangeOption.yesterday) {
      return formatter.format(targetRange.start);
    }
    return '${formatter.format(targetRange.start)} - ${formatter.format(targetRange.end)}';
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

    // Apply sorting
    switch (_sortOption) {
      case ReportSortOption.latest:
        all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case ReportSortOption.oldest:
        all.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case ReportSortOption.amountHighToLow:
        all.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ReportSortOption.amountLowToHigh:
        all.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

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

  // Cash Statement Calculations
  List<LedgerItem> get cashStatementTransactions {
    if (_txProvider == null || _debtProvider == null) return [];

    final List<LedgerItem> ledger = [];

    // Incomes/Expenses matching Cash
    for (var tx in _txProvider!.transactions) {
      if (tx.paymentMethod == 'Cash') {
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

    // Debts (all treated as Cash by default)
    for (var d in _debtProvider!.items) {
      ledger.add(LedgerItem(
        id: d.id,
        title: d.isReceive ? 'Money In' : 'Money Out',
        subtitle: '${d.name} • ${d.detail}',
        amount: d.amount,
        dateTime: d.createdAt,
        isCredit: d.isReceive,
      ));
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

  double get cashClosingBalance {
    final transactions = cashStatementTransactions;
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

  // 5. Parties Report Calculations
  List<PartyReportSummary> get partyReportSummaries {
    if (_debtProvider == null) return [];

    // Group debt items by party name
    final Map<String, List<DebtItem>> grouped = {};
    for (var item in _debtProvider!.items) {
      grouped.putIfAbsent(item.name, () => []).add(item);
    }

    final List<PartyReportSummary> summaries = [];
    grouped.forEach((name, items) {
      double net = 0.0;
      String? phone;

      for (var item in items) {
        if (item.phone != null) phone = item.phone;
        if (item.isReceive) {
          net += item.amount;
        } else {
          net -= item.amount;
        }
      }

      summaries.add(PartyReportSummary(
        name: name,
        phone: phone,
        netBalance: net,
        transactionCount: items.length,
      ));
    });

    // Filter by search query
    return summaries.where((item) {
      if (_partiesSearchQuery.trim().isEmpty) return true;
      final q = _partiesSearchQuery.toLowerCase().trim();
      final matchName = item.name.toLowerCase().contains(q);
      final matchPhone = item.phone?.toLowerCase().contains(q) ?? false;
      return matchName || matchPhone;
    }).toList();
  }
}
