import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_trend_chart.dart';
import 'package:flutter/material.dart';

class IncomeWeeklySection extends StatelessWidget {
  const IncomeWeeklySection({super.key});

  static final List<WeeklyChartData> _weeklyChartData = [
    WeeklyChartData('Mon', 120),
    WeeklyChartData('Tue', 250),
    WeeklyChartData('Wed', 480, isHighlighted: true),
    WeeklyChartData('Thu', 310),
    WeeklyChartData('Fri', 200),
    WeeklyChartData('Sat', 150),
    WeeklyChartData('Sun', 340),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WeeklyTrendChart(data: _weeklyChartData),
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
            child: Text(
              'View All',
              style: AppTextStyles.viewAllText,
            ),
          ),
          children: [
            TransactionContainerRow(
              icon: Icons.work_outline,
              title: 'Freelance Project Payment',
              subtitle: 'Oct 24, 2023 • Digital Services',
              amount: '+${context.currencySymbol}1,200.00',
            ),
            TransactionContainerRow(
              icon: Icons.account_balance_outlined,
              title: 'Dividends Reinvestment',
              subtitle: 'Oct 22, 2023 • Investment',
              amount: '+${context.currencySymbol}450.00',
            ),
            TransactionContainerRow(
              icon: Icons.receipt_long_outlined,
              title: 'Consulting Fee',
              subtitle: 'Oct 20, 2023 • Consultation',
              amount: '+${context.currencySymbol}200.00',
            ),
          ],
        ),
      ],
    );
  }
}
