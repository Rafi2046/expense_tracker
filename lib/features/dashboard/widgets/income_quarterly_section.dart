import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/quarterly_trend_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:flutter/material.dart';

class IncomeQuarterlySection extends StatelessWidget {
  const IncomeQuarterlySection({super.key});

  static final List<QuarterlyChartData> _quarterlyChartData = [
    QuarterlyChartData('JUL', 6400),
    QuarterlyChartData('AUG', 5800),
    QuarterlyChartData('SEP', 7200, isHighlighted: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuarterlyTrendChart(data: _quarterlyChartData),
        const SizedBox(height: 24),
        TransactionListContainer(
          title: 'Major Quarterly Earnings',
          trailing: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Download PDF\nReport',
              style: AppTextStyles.viewAllText,
              textAlign: TextAlign.end,
            ),
          ),
          children: [
            TransactionContainerRow(
              icon: Icons.receipt_long_outlined,
              title: 'Senior Consultant Retainer',
              subtitle: 'Vertex Global Solutions • Monthly Recurring',
              amount: '${context.currencySymbol}15,000.00',
              subAmountLabel: 'Total for Q3',
            ),
            TransactionContainerRow(
              icon: Icons.account_balance_outlined,
              title: 'Stock Portfolio Dividends',
              subtitle: 'Vanguard Total Stock Market • Distributed Sep 15',
              amount: '${context.currencySymbol}4,210.50',
              subAmountLabel: 'One-time Event',
            ),
            TransactionContainerRow(
              icon: Icons.work_outline,
              title: 'UI Audit Freelance',
              subtitle: 'Fintech Startup X • Project Complete',
              amount: '${context.currencySymbol}3,500.00',
              subAmountLabel: 'Invoice #4402',
            ),
            TransactionContainerRow(
              icon: Icons.home_work_outlined,
              title: 'Rental Property Income',
              subtitle: 'Unit 4B - Oakwood Gardens • Net Profit',
              amount: '${context.currencySymbol}1,849.50',
              subAmountLabel: 'Total for Q3',
            ),
          ],
        ),
      ],
    );
  }
}
