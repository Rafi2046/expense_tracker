import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_transaction_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_trend_chart.dart';
import 'package:flutter/material.dart';

class IncomeMonthlySection extends StatelessWidget {
  const IncomeMonthlySection({super.key});

  static final List<ChartData> _chartData = [
    ChartData('JAN', 4200),
    ChartData('FEB', 4800),
    ChartData('MAR', 5100),
    ChartData('APR', 5800),
    ChartData('MAY', 5500),
    ChartData('JUN', 8420, isCurrent: true),
    ChartData('JUL', 6400),
    ChartData('AUG', 5800),
    ChartData('SEP', 7200),
    ChartData('OCT', 6900),
    ChartData('NOV', 7400),
    ChartData('DEC', 7900),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IncomeTrendChart(data: _chartData),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Income', style: AppTextStyles.sectionHeaderTitle),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('View All', style: AppTextStyles.viewAllText),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            IncomeTransactionRow(
              icon: Icons.account_balance_outlined,
              title: 'Monthly Salary',
              subtitle: 'Oct 24, 2023 • Tech Corp',
              amount: '+${context.currencySymbol}5,200.00',
              status: 'completed',
            ),
            const SizedBox(height: 12),
            IncomeTransactionRow(
              icon: Icons.work_outline_rounded,
              title: 'Freelance Project',
              subtitle: 'Oct 20, 2023 • UI Design',
              amount: '+${context.currencySymbol}1,850.00',
              status: 'completed',
            ),
            const SizedBox(height: 12),
            IncomeTransactionRow(
              icon: Icons.show_chart_rounded,
              title: 'Stock Dividends',
              subtitle: 'Oct 18, 2023 • Portfolio',
              amount: '+${context.currencySymbol}420.00',
              status: 'completed',
            ),
            const SizedBox(height: 12),
            IncomeTransactionRow(
              icon: Icons.home_work_outlined,
              title: 'Rental Income',
              subtitle: 'Oct 15, 2023 • Apt 4B',
              amount: '+${context.currencySymbol}950.00',
              status: 'completed',
            ),
          ],
        ),
      ],
    );
  }
}
