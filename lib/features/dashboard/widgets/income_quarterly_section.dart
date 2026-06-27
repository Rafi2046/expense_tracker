import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/quarterly_trend_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IncomeQuarterlySection extends StatelessWidget {
  final bool isMasked;

  const IncomeQuarterlySection({super.key, required this.isMasked});

  TextStyle get _amountStyle => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF2EBD85),
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<IncomeAnalyticsProvider>();
    final quarterlyTransactions = analytics.quarterlyTransactions;

    // Determine current quarter title (e.g. Q3)
    final quarter = ((DateTime.now().month - 1) ~/ 3) + 1;
    final quarterTitle = 'Q$quarter';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuarterlyTrendChart(data: analytics.quarterlyChartData),
        const SizedBox(height: 24),
        TransactionListContainer(
          title: 'Major Quarterly Earnings ($quarterTitle)',
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
          children: quarterlyTransactions.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('No income transactions this quarter')),
                  )
                ]
              : quarterlyTransactions.map((tx) {
                  IconData icon;
                  final categoryLower = tx.category.toLowerCase();
                  if (categoryLower.contains('salary')) {
                    icon = Symbols.account_balance;
                  } else if (categoryLower.contains('freelance') || categoryLower.contains('business') || categoryLower.contains('work')) {
                    icon = Symbols.work_outline;
                  } else if (categoryLower.contains('dividend') || categoryLower.contains('invest') || categoryLower.contains('saving')) {
                    icon = Symbols.savings;
                  } else {
                    icon = Symbols.receipt_long;
                  }
                  return TransactionContainerRow(
                    icon: icon,
                    title: tx.note.isNotEmpty ? tx.note : tx.category,
                    subtitle: '${DateFormat('MMM dd, yyyy').format(tx.dateTime)} • ${tx.category}',
                    amount: PrivacyMaskedText(
                      amount: tx.amount,
                      isMasked: isMasked,
                      style: _amountStyle,
                    ),
                    subAmountLabel: tx.note.isNotEmpty ? tx.category : 'Income',
                  );
                }).toList(),
        ),
      ],
    );
  }
}
