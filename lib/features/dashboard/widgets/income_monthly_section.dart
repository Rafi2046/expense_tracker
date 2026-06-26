import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_transaction_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IncomeMonthlySection extends StatelessWidget {
  const IncomeMonthlySection({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<IncomeAnalyticsProvider>();
    final monthlyTransactions = analytics.monthlyTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IncomeTrendChart(data: analytics.monthlyChartData),
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
        monthlyTransactions.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No income transactions this month')),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthlyTransactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = monthlyTransactions[index];
                  IconData icon;
                  final categoryLower = tx.category.toLowerCase();
                  if (categoryLower.contains('salary')) {
                    icon = Symbols.account_balance;
                  } else if (categoryLower.contains('freelance') || categoryLower.contains('business') || categoryLower.contains('work')) {
                    icon = Symbols.work_outline_rounded;
                  } else if (categoryLower.contains('dividend') || categoryLower.contains('invest') || categoryLower.contains('saving')) {
                    icon = Symbols.show_chart_rounded;
                  } else {
                    icon = Symbols.home_work;
                  }
                  return IncomeTransactionRow(
                    icon: icon,
                    title: tx.note.isNotEmpty ? tx.note : tx.category,
                    subtitle: '${DateFormat('MMM dd, yyyy').format(tx.dateTime)} • ${tx.category}',
                    amount: '+${context.currencySymbol}${tx.amount.toStringAsFixed(2)}',
                    status: 'completed',
                  );
                },
              ),
      ],
    );
  }
}
