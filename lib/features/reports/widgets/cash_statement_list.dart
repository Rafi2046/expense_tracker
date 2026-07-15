import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/reports/pages/cash_statement_details_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CashStatementList extends StatelessWidget {
  final bool isMasked;

  const CashStatementList({super.key, this.isMasked = false});

  static Widget buildTxCard(BuildContext context, dynamic tx, bool isMasked) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTextStyles.reportTransactionTitle.copyWith(fontSize: AppFontSizes.size14, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.subtitle}\n${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    fontSize: AppFontSizes.size11,
                    height: 1.25,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              Text(
                context.translate('bal_label'),
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: theme.primaryColor,
                        fontSize: AppFontSizes.size11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    PrivacyMaskedText(
                      amount: tx.runningBalance,
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: theme.primaryColor,
                        fontSize: AppFontSizes.size11,
                        fontWeight: FontWeight.w600,
                      ),
                      isMasked: isMasked,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PrivacyMaskedText(
            amount: tx.amount,
            style: AppTextStyles.reportTransactionTitle.copyWith(
              fontSize: AppFontSizes.size14,
              color: tx.isCredit ? theme.primaryColor : AppColors.activeRed,
            ),
            isMasked: isMasked,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.cashStatementTransactions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(LucideIcons.wallet, color: isDark ? Colors.white24 : Colors.grey.shade300, size: 48),
              const SizedBox(height: 12),
              Text(
                context.translate('no_cash_transactions_found'),
                style: AppTextStyles.reportTransactionSubtitle.copyWith(
                  fontSize: AppFontSizes.size14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final showViewAll = filtered.length > 5;
    final displayList = showViewAll ? filtered.take(5).toList() : filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.translate('transaction_lists'),
              style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
            ),
            if (showViewAll)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CashStatementDetailsScreen(isMasked: isMasked),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(context.translate('view_all'), style: AppTextStyles.viewAllText),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => buildTxCard(context, displayList[index], isMasked),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }
}
