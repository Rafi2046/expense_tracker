import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';

class IncomeExpenseSummaryCard extends StatelessWidget {
  final bool isMasked;

  const IncomeExpenseSummaryCard({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final data = reportsProvider.incomeExpenseData;
    final theme = Theme.of(context);

    final double totalIncome = data['totalIncome'] ?? 0.0;
    final double totalExpense = data['totalExpense'] ?? 0.0;
    final double netProfit = data['netProfit'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            netProfit >= 0 ? context.translate('net_profit') : context.translate('net_loss'),
            style: AppTextStyles.reportStatLabel.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          PrivacyMaskedText(
            amount: netProfit.abs(),
            isMasked: isMasked,
            style: AppTextStyles.reportLargeValue.copyWith(
              color: netProfit >= 0 ? theme.primaryColor : AppColors.activeRed,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('total_income'),
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    PrivacyMaskedText(
                      amount: totalIncome,
                      isMasked: isMasked,
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: theme.dividerTheme.color ?? Colors.grey.shade100),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('total_expense'),
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    PrivacyMaskedText(
                      amount: totalExpense,
                      isMasked: isMasked,
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        color: AppColors.activeRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
