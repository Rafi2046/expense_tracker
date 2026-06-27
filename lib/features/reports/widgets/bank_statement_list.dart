import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';

class BankStatementList extends StatelessWidget {
  final bool isMasked;

  const BankStatementList({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.bankStatementTransactions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.text_snippet,
                  size: 72,
                  color: isDark ? Colors.white30 : Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Transaction Found',
                style: AppTextStyles.reportAppBarTitle.copyWith(color: theme.colorScheme.onSurface),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFE8F8F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Bal: ',
                                style: AppTextStyles.reportStatLabel.copyWith(
                                  color: theme.primaryColor,
                                  fontSize: 10,
                                ),
                              ),
                              PrivacyMaskedText(
                                amount: tx.runningBalance,
                                style: AppTextStyles.reportStatLabel.copyWith(
                                  color: theme.primaryColor,
                                  fontSize: 10,
                                ),
                                isMasked: isMasked,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrivacyMaskedText(
                    amount: tx.amount,
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      fontSize: 14,
                      color: tx.isCredit ? theme.primaryColor : AppColors.activeRed,
                    ),
                    isMasked: isMasked,
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
