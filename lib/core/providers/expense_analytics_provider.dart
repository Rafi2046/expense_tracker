import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_trend_chart_card.dart' show ExpenseChartData;
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_item.dart' show CategoryBreakdownItem;
import 'package:expense_tracker/features/dashboard/widgets/expense_breakdown_card.dart' show ExpenseBreakdownItem;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExpenseAnalyticsProvider extends ChangeNotifier {
  List<TransactionItem> _expenseTransactions = [];

  String? _currentProfileId;
  StreamSubscription<User?>? _authSubscription;

  static const _categoryColors = [
    Color(0xFF10B981), // Emerald green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Hot pink
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF14B8A6), // Teal
    Color(0xFF3B82F6), // Blue
    Color(0xFFF97316), // Orange
  ];

  ExpenseAnalyticsProvider() {
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    if (newUser == null) {
      _expenseTransactions = [];
      _currentProfileId = null;
      notifyListeners();
    }
  }

  void updateTransactions(List<TransactionItem> transactions) {
    final newExpenses = transactions.where((tx) => !tx.isIncome).toList();

    if (_isListEqual(newExpenses, _expenseTransactions)) {
      return;
    }

    _expenseTransactions = newExpenses;
    notifyListeners();
  }

  bool _isListEqual(List<TransactionItem> a, List<TransactionItem> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].amount != b[i].amount ||
          a[i].dateTime != b[i].dateTime ||
          a[i].category != b[i].category ||
          a[i].note != b[i].note) {
        return false;
      }
    }
    return true;
  }

  Color _categoryColor(String category) {
    final palette = _categoryColors;
    final index = category.toLowerCase().hashCode % palette.length;
    return palette[index.abs()];
  }

  // ─── DAILY ──────────────────────────────────────────────────────

  double get todayExpense {
    final now = DateTime.now();
    return _expenseTransactions
        .where((tx) =>
            tx.dateTime.year == now.year &&
            tx.dateTime.month == now.month &&
            tx.dateTime.day == now.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get yesterdayExpense {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _expenseTransactions
        .where((tx) =>
            tx.dateTime.year == yesterday.year &&
            tx.dateTime.month == yesterday.month &&
            tx.dateTime.day == yesterday.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get dailyPercentageChange {
    final prev = yesterdayExpense;
    final curr = todayExpense;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get todayTransactions {
    final now = DateTime.now();
    final list = _expenseTransactions
        .where((tx) =>
            tx.dateTime.year == now.year &&
            tx.dateTime.month == now.month &&
            tx.dateTime.day == now.day)
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ExpenseChartData> get dailyChartData {
    final now = DateTime.now();
    final bins = List<double>.filled(12, 0.0);

    for (final tx in _expenseTransactions) {
      if (tx.dateTime.year == now.year &&
          tx.dateTime.month == now.month &&
          tx.dateTime.day == now.day) {
        final binIndex = (tx.dateTime.hour ~/ 2).clamp(0, 11);
        bins[binIndex] += tx.amount;
      }
    }

    final labels = [
      '00:00', ' ', '  ', '06:00', '   ', '    ',
      '12:00', '     ', '      ', '18:00', '       ', '23:59',
    ];
    final currentBin = (now.hour ~/ 2).clamp(0, 11);

    return List.generate(12, (i) {
      return ExpenseChartData(labels[i], bins[i], isHighlighted: i == currentBin);
    });
  }

  // ─── WEEKLY ─────────────────────────────────────────────────────

  DateTime get _startOfCurrentWeek {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  double get currentWeekExpense {
    final start = _startOfCurrentWeek;
    final end = start.add(const Duration(days: 7));
    return _expenseTransactions
        .where((tx) =>
            tx.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tx.dateTime.isBefore(end))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousWeekExpense {
    final start = _startOfCurrentWeek.subtract(const Duration(days: 7));
    final end = start.add(const Duration(days: 7));
    return _expenseTransactions
        .where((tx) =>
            tx.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tx.dateTime.isBefore(end))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get weeklyPercentageChange {
    final prev = previousWeekExpense;
    final curr = currentWeekExpense;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get weeklyTransactions {
    final start = _startOfCurrentWeek;
    final end = start.add(const Duration(days: 7));
    final list = _expenseTransactions
        .where((tx) =>
            tx.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tx.dateTime.isBefore(end))
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ExpenseChartData> get weeklyChartData {
    final start = _startOfCurrentWeek;
    final now = DateTime.now();
    final values = List<double>.filled(7, 0.0);

    for (final tx in _expenseTransactions) {
      final diff = tx.dateTime.difference(start).inDays;
      if (diff >= 0 && diff < 7) {
        values[diff] += tx.amount;
      }
    }

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDayIndex = now.weekday - 1;

    return List.generate(7, (i) {
      return ExpenseChartData(dayLabels[i], values[i], isHighlighted: i == currentDayIndex);
    });
  }

  // ─── MONTHLY ────────────────────────────────────────────────────

  double get currentMonthExpense {
    final now = DateTime.now();
    return _expenseTransactions
        .where((tx) => tx.dateTime.year == now.year && tx.dateTime.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousMonthExpense {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    return _expenseTransactions
        .where((tx) =>
            tx.dateTime.year == prevMonth.year && tx.dateTime.month == prevMonth.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyPercentageChange {
    final prev = previousMonthExpense;
    final curr = currentMonthExpense;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get monthlyTransactions {
    final now = DateTime.now();
    final list = _expenseTransactions
        .where((tx) => tx.dateTime.year == now.year && tx.dateTime.month == now.month)
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ExpenseChartData> get monthlyChartData {
    final now = DateTime.now();
    final result = <ExpenseChartData>[];
    final monthLabels = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];

    for (int i = 11; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      final sum = _expenseTransactions
          .where((tx) =>
              tx.dateTime.year == target.year && tx.dateTime.month == target.month)
          .fold(0.0, (s, tx) => s + tx.amount);

      result.add(ExpenseChartData(
        monthLabels[target.month - 1],
        sum,
        isHighlighted: i == 0,
      ));
    }
    return result;
  }

  List<CategoryBreakdownItem> get monthlyCategories {
    final now = DateTime.now();
    final grouped = <String, double>{};

    for (final tx in _expenseTransactions) {
      if (tx.dateTime.year == now.year && tx.dateTime.month == now.month) {
        final key = tx.category;
        grouped[key] = (grouped[key] ?? 0) + tx.amount;
      }
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    return grouped.entries.map((e) {
      return CategoryBreakdownItem(
        name: e.key,
        amount: e.value,
        percentage: total > 0 ? (e.value / total) * 100 : 0,
        color: _categoryColor(e.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  // ─── QUARTERLY ──────────────────────────────────────────────────

  int get _currentQuarter => ((DateTime.now().month - 1) ~/ 3) + 1;

  List<int> get _monthsInCurrentQuarter {
    final q = _currentQuarter;
    final startMonth = (q - 1) * 3 + 1;
    return [startMonth, startMonth + 1, startMonth + 2];
  }

  double get currentQuarterExpense {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    return _expenseTransactions
        .where((tx) => tx.dateTime.year == now.year && months.contains(tx.dateTime.month))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousQuarterExpense {
    final now = DateTime.now();
    final currentQ = _currentQuarter;
    final prevYear = currentQ == 1 ? now.year - 1 : now.year;
    final prevQ = currentQ == 1 ? 4 : currentQ - 1;
    final startMonth = (prevQ - 1) * 3 + 1;
    final prevMonths = [startMonth, startMonth + 1, startMonth + 2];

    return _expenseTransactions
        .where((tx) => tx.dateTime.year == prevYear && prevMonths.contains(tx.dateTime.month))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get quarterlyPercentageChange {
    final prev = previousQuarterExpense;
    final curr = currentQuarterExpense;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get quarterlyTransactions {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    final list = _expenseTransactions
        .where((tx) => tx.dateTime.year == now.year && months.contains(tx.dateTime.month))
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ExpenseChartData> get quarterlyChartData {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    final values = List<double>.filled(3, 0.0);

    for (final tx in _expenseTransactions) {
      if (tx.dateTime.year == now.year) {
        final idx = months.indexOf(tx.dateTime.month);
        if (idx != -1) {
          values[idx] += tx.amount;
        }
      }
    }

    final monthLabels = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];

    return List.generate(3, (i) {
      final monthNum = months[i];
      return ExpenseChartData(
        monthLabels[monthNum - 1],
        values[i],
        isHighlighted: monthNum == now.month,
      );
    });
  }

  List<CategoryBreakdownItem> get quarterlyCategories {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    final grouped = <String, double>{};

    for (final tx in _expenseTransactions) {
      if (tx.dateTime.year == now.year && months.contains(tx.dateTime.month)) {
        final key = tx.category;
        grouped[key] = (grouped[key] ?? 0) + tx.amount;
      }
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    return grouped.entries.map((e) {
      return CategoryBreakdownItem(
        name: e.key,
        amount: e.value,
        percentage: total > 0 ? (e.value / total) * 100 : 0,
        color: _categoryColor(e.key),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  List<ExpenseBreakdownItem> get quarterlyBreakdowns {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    final Map<String, double> amountByAccount = {};
    final Map<String, int> countByAccount = {};

    for (final tx in _expenseTransactions) {
      if (tx.dateTime.year == now.year && months.contains(tx.dateTime.month)) {
        final acct = tx.paymentMethod;
        amountByAccount[acct] = (amountByAccount[acct] ?? 0.0) + tx.amount;
        countByAccount[acct] = (countByAccount[acct] ?? 0) + 1;
      }
    }

    final items = <ExpenseBreakdownItem>[];

    if ((countByAccount['Cash'] ?? 0) > 0) {
      items.add(ExpenseBreakdownItem(
        title: 'Cash',
        subtitle: '${countByAccount['Cash']} transactions',
        amount: amountByAccount['Cash']!.toStringAsFixed(0),
        icon: LucideIcons.creditCard,
      ));
    }

    if ((countByAccount['Bank'] ?? 0) > 0) {
      items.add(ExpenseBreakdownItem(
        title: 'Bank',
        subtitle: '${countByAccount['Bank']} transactions',
        amount: amountByAccount['Bank']!.toStringAsFixed(0),
        icon: LucideIcons.landmark,
      ));
    }

    for (final entry in countByAccount.entries) {
      if (entry.key != 'Cash' && entry.key != 'Bank') {
        items.add(ExpenseBreakdownItem(
          title: entry.key,
          subtitle: '${entry.value} transactions',
          amount: amountByAccount[entry.key]!.toStringAsFixed(0),
          icon: LucideIcons.wallet,
        ));
      }
    }

    return items;
  }

  void updateProfileId(String newProfileId) {
    if (_currentProfileId == newProfileId) return;
    _currentProfileId = newProfileId;
    _expenseTransactions = [];
    notifyListeners();
  }

  void clear() {
    _expenseTransactions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
