import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';

void main() {
  group('IncomeAnalyticsProvider Tests', () {
    late IncomeAnalyticsProvider provider;

    setUp(() {
      provider = IncomeAnalyticsProvider();
    });

    test('initial state has zero totals', () {
      provider.updateTransactions([]);
      expect(provider.todayIncome, 0.0);
      expect(provider.yesterdayIncome, 0.0);
      expect(provider.dailyPercentageChange, 0.0);
      expect(provider.currentWeekIncome, 0.0);
      expect(provider.weeklyPercentageChange, 0.0);
      expect(provider.currentMonthIncome, 0.0);
      expect(provider.monthlyPercentageChange, 0.0);
      expect(provider.currentQuarterIncome, 0.0);
      expect(provider.quarterlyPercentageChange, 0.0);
    });

    test('correctly filters isIncome == true and computes daily stats', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final txs = [
        TransactionItem(
          id: '1',
          amount: 150.0,
          category: 'Salary',
          note: 'Paycheck',
          isIncome: true,
          dateTime: now,
        ),
        TransactionItem(
          id: '2',
          amount: 50.0,
          category: 'Freelance',
          note: 'Gig',
          isIncome: true,
          dateTime: now.add(const Duration(seconds: 10)),
        ),
        TransactionItem(
          id: '3',
          amount: 100.0,
          category: 'Food',
          note: 'Lunch',
          isIncome: false,
          dateTime: now,
        ),
        TransactionItem(
          id: '4',
          amount: 100.0,
          category: 'Bonus',
          note: 'Holiday Bonus',
          isIncome: true,
          dateTime: yesterday,
        ),
      ];

      provider.updateTransactions(txs);

      // Today income = 150 + 50 = 200
      expect(provider.todayIncome, 200.0);
      // Yesterday income = 100
      expect(provider.yesterdayIncome, 100.0);
      // Change vs yesterday = (200 - 100) / 100 = 100%
      expect(provider.dailyPercentageChange, 100.0);
      // Only today's income transactions returned
      expect(provider.todayTransactions.length, 2);
      expect(provider.todayTransactions[0].id, '2'); // sorted latest first
    });

    test('correctly computes weekly trend chart data', () {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));

      final txs = [
        TransactionItem(
          id: 'w1',
          amount: 500.0,
          category: 'Consulting',
          note: 'Client payment',
          isIncome: true,
          dateTime: monday, // Monday of current week
        ),
      ];

      provider.updateTransactions(txs);

      final chart = provider.weeklyChartData;
      expect(chart.length, 7);
      expect(chart[0].value, 500.0);
      expect(chart[0].dayLabel, 'Mon');
    });
  });
}
