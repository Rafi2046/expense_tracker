import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/daily_distribution_chart.dart' show DailyChartData;
import 'package:expense_tracker/features/dashboard/widgets/weekly_trend_chart.dart' show WeeklyChartData;
import 'package:expense_tracker/features/dashboard/widgets/income_trend_chart.dart' show ChartData;
import 'package:expense_tracker/features/dashboard/widgets/quarterly_trend_chart.dart' show QuarterlyChartData;

class IncomeAnalyticsProvider extends ChangeNotifier {
  List<TransactionItem> _incomeTransactions = [];

  String? _currentProfileId;
  StreamSubscription<User?>? _authSubscription;

  IncomeAnalyticsProvider() {
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      _onAuthChanged(user);
    });
  }

  void _onAuthChanged(User? newUser) {
    if (newUser == null) {
      _incomeTransactions = [];
      _currentProfileId = null;
      notifyListeners();
    }
  }

  void updateTransactions(List<TransactionItem> transactions) {
    final newIncomes = transactions.where((tx) => tx.isIncome).toList();

    if (_isListEqual(newIncomes, _incomeTransactions)) {
      return;
    }

    _incomeTransactions = newIncomes;
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

  // ─── DAILY CALCULATIONS ─────────────────────────────────────────

  double get todayIncome {
    final now = DateTime.now();
    return _incomeTransactions
        .where((tx) => tx.dateTime.year == now.year && tx.dateTime.month == now.month && tx.dateTime.day == now.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get yesterdayIncome {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _incomeTransactions
        .where((tx) => tx.dateTime.year == yesterday.year && tx.dateTime.month == yesterday.month && tx.dateTime.day == yesterday.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get dailyPercentageChange {
    final yesterday = yesterdayIncome;
    final today = todayIncome;
    if (yesterday == 0) return today > 0 ? 100.0 : 0.0;
    return ((today - yesterday) / yesterday) * 100.0;
  }

  List<TransactionItem> get todayTransactions {
    final now = DateTime.now();
    final list = _incomeTransactions
        .where((tx) => tx.dateTime.year == now.year && tx.dateTime.month == now.month && tx.dateTime.day == now.day)
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<DailyChartData> get dailyChartData {
    final now = DateTime.now();
    final bins = List<double>.filled(12, 0.0);

    for (final tx in _incomeTransactions) {
      if (tx.dateTime.year == now.year && tx.dateTime.month == now.month && tx.dateTime.day == now.day) {
        final hour = tx.dateTime.hour;
        final binIndex = (hour ~/ 2).clamp(0, 11);
        bins[binIndex] += tx.amount;
      }
    }

    final labels = ['00:00', ' ', '  ', '06:00', '   ', '    ', '12:00', '     ', '      ', '18:00', '       ', '23:59'];
    final currentBin = (now.hour ~/ 2).clamp(0, 11);

    return List.generate(12, (i) {
      return DailyChartData(
        labels[i],
        bins[i],
        isHighlighted: i == currentBin,
      );
    });
  }

  // ─── WEEKLY CALCULATIONS ────────────────────────────────────────

  DateTime get _startOfCurrentWeek {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  }

  double get currentWeekIncome {
    final startOfWeek = _startOfCurrentWeek;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _incomeTransactions
        .where((tx) => tx.dateTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && tx.dateTime.isBefore(endOfWeek))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousWeekIncome {
    final startOfWeek = _startOfCurrentWeek.subtract(const Duration(days: 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return _incomeTransactions
        .where((tx) => tx.dateTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && tx.dateTime.isBefore(endOfWeek))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get weeklyPercentageChange {
    final prev = previousWeekIncome;
    final curr = currentWeekIncome;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get weeklyTransactions {
    final startOfWeek = _startOfCurrentWeek;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final list = _incomeTransactions
        .where((tx) => tx.dateTime.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && tx.dateTime.isBefore(endOfWeek))
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<WeeklyChartData> get weeklyChartData {
    final startOfWeek = _startOfCurrentWeek;
    final now = DateTime.now();
    final dayValues = List<double>.filled(7, 0.0);

    for (final tx in _incomeTransactions) {
      final difference = tx.dateTime.difference(startOfWeek).inDays;
      if (difference >= 0 && difference < 7) {
        dayValues[difference] += tx.amount;
      }
    }

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDayIndex = now.weekday - 1;

    return List.generate(7, (i) {
      return WeeklyChartData(
        dayLabels[i],
        dayValues[i],
        isHighlighted: i == currentDayIndex,
      );
    });
  }

  // ─── MONTHLY CALCULATIONS ───────────────────────────────────────

  double get currentMonthIncome {
    final now = DateTime.now();
    return _incomeTransactions
        .where((tx) => tx.dateTime.year == now.year && tx.dateTime.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousMonthIncome {
    final now = DateTime.now();
    final prevMonthDate = DateTime(now.year, now.month - 1, 1);
    return _incomeTransactions
        .where((tx) => tx.dateTime.year == prevMonthDate.year && tx.dateTime.month == prevMonthDate.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get monthlyPercentageChange {
    final prev = previousMonthIncome;
    final curr = currentMonthIncome;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get monthlyTransactions {
    final now = DateTime.now();
    final list = _incomeTransactions
        .where((tx) => tx.dateTime.year == now.year && tx.dateTime.month == now.month)
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<ChartData> get monthlyChartData {
    final now = DateTime.now();
    final List<ChartData> result = [];
    final monthLabels = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    for (int i = 11; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final label = monthLabels[targetDate.month - 1];

      final sum = _incomeTransactions
          .where((tx) => tx.dateTime.year == targetDate.year && tx.dateTime.month == targetDate.month)
          .fold(0.0, (s, tx) => s + tx.amount);

      result.add(ChartData(
        label,
        sum,
        isCurrent: i == 0,
      ));
    }
    return result;
  }

  // ─── QUARTERLY CALCULATIONS ─────────────────────────────────────

  int get _currentQuarter {
    return ((DateTime.now().month - 1) ~/ 3) + 1;
  }

  List<int> get _monthsInCurrentQuarter {
    final q = _currentQuarter;
    final startMonth = (q - 1) * 3 + 1;
    return [startMonth, startMonth + 1, startMonth + 2];
  }

  double get currentQuarterIncome {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    return _incomeTransactions
        .where((tx) => tx.dateTime.year == now.year && months.contains(tx.dateTime.month))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get previousQuarterIncome {
    final now = DateTime.now();
    final currentQ = _currentQuarter;
    final prevYear = currentQ == 1 ? now.year - 1 : now.year;
    final prevQ = currentQ == 1 ? 4 : currentQ - 1;
    final startMonth = (prevQ - 1) * 3 + 1;
    final prevMonths = [startMonth, startMonth + 1, startMonth + 2];

    return _incomeTransactions
        .where((tx) => tx.dateTime.year == prevYear && prevMonths.contains(tx.dateTime.month))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get quarterlyPercentageChange {
    final prev = previousQuarterIncome;
    final curr = currentQuarterIncome;
    if (prev == 0) return curr > 0 ? 100.0 : 0.0;
    return ((curr - prev) / prev) * 100.0;
  }

  List<TransactionItem> get quarterlyTransactions {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    final list = _incomeTransactions
        .where((tx) => tx.dateTime.year == now.year && months.contains(tx.dateTime.month))
        .toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<QuarterlyChartData> get quarterlyChartData {
    final now = DateTime.now();
    final months = _monthsInCurrentQuarter;
    final monthValues = List<double>.filled(3, 0.0);

    for (final tx in _incomeTransactions) {
      if (tx.dateTime.year == now.year) {
        final idx = months.indexOf(tx.dateTime.month);
        if (idx != -1) {
          monthValues[idx] += tx.amount;
        }
      }
    }

    final monthLabels = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return List.generate(3, (i) {
      final monthNum = months[i];
      return QuarterlyChartData(
        monthLabels[monthNum - 1],
        monthValues[i],
        isHighlighted: monthNum == now.month,
      );
    });
  }

  void updateProfileId(String newProfileId) {
    if (_currentProfileId == newProfileId) return;
    _currentProfileId = newProfileId;
    _incomeTransactions = [];
    notifyListeners();
  }

  void clear() {
    _incomeTransactions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
