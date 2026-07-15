import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/pages/income_transaction_list_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/transaction_details_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_container_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_list_container.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeWeeklySection extends StatelessWidget {
  final bool isMasked;

  const IncomeWeeklySection({super.key, required this.isMasked});

  TextStyle get _amountStyle => TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF2EBD85),
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

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
          title: context.translate('weekly_activity'),
          trailing: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IncomeTransactionListScreen(
                  title: context.translate('weekly_activity'),
                  transactions: weeklyTransactions,
                  isMasked: isMasked,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(context.translate('view_all'), style: AppTextStyles.viewAllText),
          ),
          children: weeklyTransactions.isEmpty
              ? [
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text(context.translate('no_income_this_week'))),
                  )
                ]
              : weeklyTransactions.map((tx) {
                  IconData icon;
                  final categoryLower = tx.category.toLowerCase();
                  if (categoryLower.contains('salary')) {
                    icon = LucideIcons.landmark;
                  } else if (categoryLower.contains('freelance') || categoryLower.contains('business') || categoryLower.contains('work')) {
                    icon = LucideIcons.briefcase;
                  } else if (categoryLower.contains('dividend') || categoryLower.contains('invest') || categoryLower.contains('saving')) {
                    icon = LucideIcons.piggyBank;
                  } else {
                    icon = LucideIcons.receipt;
                  }
                  return TransactionContainerRow(
                    icon: icon,
                    title: tx.note.isNotEmpty ? tx.note : tx.category,
                    subtitle: '${DateFormat('MMM dd, yyyy').format(tx.dateTime)} • ${tx.category}',
                    amount: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('+ ', style: _amountStyle),
                        PrivacyMaskedText(
                          amount: tx.amount,
                          isMasked: isMasked,
                          style: _amountStyle,
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailsScreen(transaction: tx),
                      ),
                    ),
                  );
                }).toList(),
        ),
      ],
    );
  }
}
