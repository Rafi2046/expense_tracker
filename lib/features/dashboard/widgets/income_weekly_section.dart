import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IncomeWeeklySection extends StatelessWidget {
  const IncomeWeeklySection({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<IncomeAnalyticsProvider>();
    final weeklyTransactions = analytics.weeklyTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeeklyTrendChart(data: analytics.weeklyChartData),
        const SizedBox(height: 24),
        TransactionListContainer(
          title: 'Weekly Activity',
          trailing: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('View All', style: AppTextStyles.viewAllText),
          ),
          children: weeklyTransactions.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('No income transactions this week')),
                  )
                ]
              : weeklyTransactions.map((tx) {
                  IconData icon;
                  final categoryLower = tx.category.toLowerCase();
                  if (categoryLower.contains('salary')) {
                    icon = Icons.account_balance_outlined;
                  } else if (categoryLower.contains('freelance') || categoryLower.contains('business') || categoryLower.contains('work')) {
                    icon = Icons.work_outline;
                  } else if (categoryLower.contains('dividend') || categoryLower.contains('invest') || categoryLower.contains('saving')) {
                    icon = Icons.savings_outlined;
                  } else {
                    icon = Icons.receipt_long_outlined;
                  }
                  return TransactionContainerRow(
                    icon: icon,
                    title: tx.note.isNotEmpty ? tx.note : tx.category,
                    subtitle: '${DateFormat('MMM dd, yyyy').format(tx.dateTime)} • ${tx.category}',
                    amount: '+${context.currencySymbol}${tx.amount.toStringAsFixed(2)}',
                  );
                }).toList(),
        ),
      ],
    );
  }
}
