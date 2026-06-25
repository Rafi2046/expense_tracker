import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class CashStatementList extends StatelessWidget {
  const CashStatementList({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.cashStatementTransactions;
    final currencySymbol = context.currencySymbol;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.wallet_rounded, color: isDark ? Colors.white24 : Colors.grey.shade300, size: 48),
              const SizedBox(height: 12),
              Text(
                'No cash transactions found',
                style: AppTextStyles.reportTransactionSubtitle.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Lists',
          style: AppTextStyles.reportTransactionTitle.copyWith(fontSize: 14.5, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final tx = filtered[index];

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: AppTextStyles.reportTransactionTitle.copyWith(fontSize: 13.5, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx.subtitle}\n${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                          style: AppTextStyles.reportTransactionSubtitle.copyWith(
                            fontSize: 11,
                            height: 1.25,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Running Balance pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFE8F8F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Bal: $currencySymbol ${tx.runningBalance.toStringAsFixed(0)}',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: theme.primaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$currencySymbol ${tx.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      fontSize: 14,
                      color: tx.isCredit ? theme.primaryColor : AppColors.activeRed,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
