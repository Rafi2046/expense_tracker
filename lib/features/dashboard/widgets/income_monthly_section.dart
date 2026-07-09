import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/pages/income_transaction_list_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/transaction_details_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_transaction_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeMonthlySection extends StatelessWidget {
  final bool isMasked;

  const IncomeMonthlySection({super.key, required this.isMasked});

  TextStyle get _amountStyle => TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF2EBD85),
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text(
              'Recent Income',
              style: AppTextStyles.sectionHeaderTitle.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IncomeTransactionListScreen(
                    title: 'All Monthly Income',
                    transactions: monthlyTransactions,
                    isMasked: isMasked,
                  ),
                ),
              ),
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
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthlyTransactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = monthlyTransactions[index];
                  IconData icon;
                  final categoryLower = tx.category.toLowerCase();
                  if (categoryLower.contains('salary')) {
                    icon = LucideIcons.landmark;
                  } else if (categoryLower.contains('freelance') || categoryLower.contains('business') || categoryLower.contains('work')) {
                    icon = LucideIcons.briefcase;
                  } else if (categoryLower.contains('dividend') || categoryLower.contains('invest') || categoryLower.contains('saving')) {
                    icon = LucideIcons.lineChart;
                  } else {
                    icon = LucideIcons.building2;
                  }
                  return IncomeTransactionRow(
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
                    status: 'completed',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailsScreen(transaction: tx),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
