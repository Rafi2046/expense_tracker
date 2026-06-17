import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/daily_distribution_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:flutter/material.dart';

class IncomeDailySection extends StatelessWidget {
  const IncomeDailySection({super.key});

  static final List<DailyChartData> _dailyChartData = [
    DailyChartData('00:00', 10),
    DailyChartData(' ', 8),
    DailyChartData('  ', 6),
    DailyChartData('06:00', 12),
    DailyChartData('   ', 30),
    DailyChartData('    ', 45),
    DailyChartData('12:00', 55, isHighlighted: true),
    DailyChartData('     ', 25),
    DailyChartData('      ', 15),
    DailyChartData('18:00', 20),
    DailyChartData('       ', 10),
    DailyChartData('23:59', 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DailyDistributionChart(data: _dailyChartData),
        const SizedBox(height: 24),
        TransactionListContainer(
          title: "Today's Income",
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
              title: 'Freelance Payment',
              subtitle: 'Project: Emerald Design System',
              amount: '+${context.currencySymbol}180.00',
              subAmountLabel: '14:32',
            ),
            TransactionContainerRow(
              icon: Icons.savings_outlined,
              title: 'Dividend Yield',
              subtitle: 'Monthly Asset Distribution',
              amount: '+${context.currencySymbol}45.50',
              subAmountLabel: '10:15',
            ),
            TransactionContainerRow(
              icon: Icons.receipt_long_outlined,
              title: 'Consultation Fee',
              subtitle: 'Retainer: Weekly Sync',
              amount: '+${context.currencySymbol}14.50',
              subAmountLabel: '09:00',
            ),
          ],
        ),
      ],
    );
  }
}
