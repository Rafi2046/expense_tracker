import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/model/unified_transaction.dart';
import 'package:expense_tracker/core/model/ledger_item.dart';
import 'package:expense_tracker/core/model/category_summary.dart';
import 'package:expense_tracker/core/model/party_report_summary.dart';
import 'package:expense_tracker/core/model/party_statement_entry.dart';

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

  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;

  DateTimeRange? _selectedDateRange;
  DateRangeOption _selectedOption = DateRangeOption.thisMonth;

  String _searchQuery = '';
  String _selectedType = 'All Transactions';
  String? _selectedPartyName;
  ReportSortOption _sortOption = ReportSortOption.latest;

  String? _selectedPartyNameForStatement;

  String _partiesSearchQuery = '';

  PartyStatementViewMode _partyStatementViewMode = PartyStatementViewMode.card;

  ReportsProvider() {
    _selectedDateRange = getDateTimeRangeForOption(DateRangeOption.thisMonth);
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    _firebaseUser = newUser;
    if (newUser == null) {
      _txProvider = null;
      _debtProvider = null;
      _selectedDateRange = null;
      _selectedOption = DateRangeOption.allTime;
      _searchQuery = '';
      _selectedType = 'All Transactions';
      _selectedPartyName = null;
      _sortOption = ReportSortOption.latest;
      _selectedPartyNameForStatement = null;
      _partiesSearchQuery = '';
      _partyStatementViewMode = PartyStatementViewMode.card;
      notifyListeners();
    }
  }

  void updateProviders(TransactionProvider tx, DebtProvider debt) {
    _txProvider = tx;
    _debtProvider = debt;
    notifyListeners();
  }

  DateTimeRange? get selectedDateRange => _selectedDateRange;
  DateRangeOption get selectedOption => _selectedOption;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String? get selectedPartyName => _selectedPartyName;
  String? get selectedPartyNameForStatement => _selectedPartyNameForStatement;
  ReportSortOption get sortOption => _sortOption;
  String get partiesSearchQuery => _partiesSearchQuery;
  PartyStatementViewMode get partyStatementViewMode => _partyStatementViewMode;

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

  List<UnifiedTransaction> get filteredTransactions {
    if (_txProvider == null || _debtProvider == null) return [];

    final List<UnifiedTransaction> all = [];

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

    return all.where((tx) {
      if (_selectedDateRange != null) {
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
        if (tx.dateTime.isBefore(start) || tx.dateTime.isAfter(end)) {
          return false;
        }
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchTitle = tx.title.toLowerCase().contains(q);
        final matchSubtitle = tx.subtitle.toLowerCase().contains(q);
        final matchParty = tx.partyName?.toLowerCase().contains(q) ?? false;
        if (!matchTitle && !matchSubtitle && !matchParty) {
          return false;
        }
      }

      if (_selectedType != 'All Transactions') {
        if (tx.type != _selectedType) return false;
      }

      if (_selectedPartyName != null) {
        if (tx.partyName != _selectedPartyName) return false;
      }

      return true;
    }).toList();
  }

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

  List<PartyStatementEntry> get partyStatementTransactions {
    if (_selectedPartyNameForStatement == null) return [];
    final List<PartyStatementEntry> entries = [];

    final partyName = _selectedPartyNameForStatement!;

    bool inDateRange(DateTime dt) {
      if (_selectedDateRange == null) return true;
      final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
      final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
      return !dt.isBefore(start) && !dt.isAfter(end);
    }

    if (_debtProvider != null) {
      for (var item in _debtProvider!.items) {
        if (item.name != partyName) continue;
        if (!inDateRange(item.createdAt)) continue;
        entries.add(PartyStatementEntry(
          id: 'debt_${item.id}',
          partyName: item.name,
          description: item.detail,
          amount: item.amount,
          isInflow: item.isReceive,
          dateTime: item.createdAt,
          isOpeningBalance: item.detail.toLowerCase().contains('opening balance'),
        ));
      }
    }

    if (_txProvider != null) {
      for (var item in _txProvider!.transactions) {
        if (item.partyName != partyName) continue;
        if (!inDateRange(item.dateTime)) continue;
        entries.add(PartyStatementEntry(
          id: 'tx_${item.id}',
          partyName: item.partyName!,
          description: item.note.isNotEmpty ? item.note : item.category,
          amount: item.amount,
          isInflow: item.isIncome,
          dateTime: item.dateTime,
        ));
      }
    }

    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return entries;
  }

  Map<String, dynamic> get partyStatementTotals {
    double receiveTotal = 0.0;
    double giveTotal = 0.0;
    for (var entry in partyStatementTransactions) {
      if (entry.isInflow) {
        receiveTotal += entry.amount;
      } else {
        giveTotal += entry.amount;
      }
    }
    final netBalance = receiveTotal - giveTotal;
    return {
      'receiveTotal': receiveTotal,
      'giveTotal': giveTotal,
      'netBalance': netBalance,
    };
  }

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

  List<LedgerItem> get cashStatementTransactions {
    if (_txProvider == null || _debtProvider == null) return [];

    final List<LedgerItem> ledger = [];

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

  List<PartyReportSummary> get partyReportSummaries {
    if (_debtProvider == null) return [];

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

    return summaries.where((item) {
      if (_partiesSearchQuery.trim().isEmpty) return true;
      final q = _partiesSearchQuery.toLowerCase().trim();
      final matchName = item.name.toLowerCase().contains(q);
      final matchPhone = item.phone?.toLowerCase().contains(q) ?? false;
      return matchName || matchPhone;
    }).toList();
  }

  void updateProfileId(String newProfileId) {
    _txProvider = null;
    _debtProvider = null;
    _selectedDateRange = getDateTimeRangeForOption(DateRangeOption.thisMonth);
    _selectedOption = DateRangeOption.thisMonth;
    _searchQuery = '';
    _selectedType = 'All Transactions';
    _selectedPartyName = null;
    _sortOption = ReportSortOption.latest;
    _selectedPartyNameForStatement = null;
    _partiesSearchQuery = '';
    _partyStatementViewMode = PartyStatementViewMode.card;
    notifyListeners();
  }

  void clear() {
    _txProvider = null;
    _debtProvider = null;
    _selectedDateRange = null;
    _selectedOption = DateRangeOption.allTime;
    _searchQuery = '';
    _selectedType = 'All Transactions';
    _selectedPartyName = null;
    _sortOption = ReportSortOption.latest;
    _selectedPartyNameForStatement = null;
    _partiesSearchQuery = '';
    _partyStatementViewMode = PartyStatementViewMode.card;
    _firebaseUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
