import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_progress_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/over_budget_warning.dart';
import 'package:expense_tracker/features/dashboard/widgets/set_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double monthlyExpense;

  const BudgetSummaryCard({super.key, required this.monthlyExpense});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final txProvider = context.watch<TransactionProvider>();

    // Wait until BOTH limit and expenses have finished their initial hydrate
    // so red/green is never evaluated against a half-loaded pair.
    final isResolving = budgetProvider.isLoading || txProvider.isLoading;
    if (isResolving) {
      // Keep a sized shell so the parent Skeletonizer has something to shimmer.
      return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.br8),
          side: BorderSide(color: AppColors.borderColor.withValues(alpha: 0.2)),
        ),
        child: const SizedBox(height: AppSpacing.s48 * 2 + AppSpacing.s24, width: double.infinity),
      );
    }

    final percentage = budgetProvider.hasBudget
        ? (monthlyExpense / budgetProvider.amount) * 100
        : 0.0;
    final isOver = percentage > 100;
    final remaining = budgetProvider.amount - monthlyExpense;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.br8),
        side: BorderSide(color: AppColors.borderColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.br8),
        onTap: () => _showSetBudgetDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.translate('monthly_budget'),
                    style: AppTextStyles.cardTitle,
                  ),
                  budgetProvider.hasBudget
                      ? PrivacyMaskedText(
                          amount: budgetProvider.amount,
                          style: AppTextStyles.cardStatusText,
                        )
                      : Text(context.translate('tap_to_set'), style: AppTextStyles.cardStatusText),
                ],
              ),
              if (budgetProvider.hasBudget) ...[
                const SizedBox(height: AppSpacing.s16),
                BudgetProgressSection(
                  percentage: percentage,
                  spent: monthlyExpense,
                  budget: budgetProvider.amount,
                ),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryLabel(
                        label: context.translate('spent'),
                        value: PrivacyMaskedText(
                          amount: monthlyExpense,
                          style: AppTextStyles.cardValueGreen.copyWith(
                            color: isOver ? AppColors.activeRed : AppColors.activeGreen,
                          ),
                        ),
                        color: isOver ? AppColors.activeRed : AppColors.activeGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: _SummaryLabel(
                        label: context.translate('remaining'),
                        value: PrivacyMaskedText(
                          amount: remaining,
                          style: AppTextStyles.cardValueGreen.copyWith(
                            color: isOver ? AppColors.activeRed : AppColors.buttonColor,
                          ),
                        ),
                        color: isOver ? AppColors.activeRed : AppColors.buttonColor,
                      ),
                    ),
                  ],
                ),
                if (isOver) ...[
                  const SizedBox(height: AppSpacing.s12),
                  OverBudgetWarning(excessAmount: remaining.abs()),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) async {
    final budgetProvider = context.read<BudgetProvider>();
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => SetBudgetDialog(currentAmount: budgetProvider.amount),
    );
    if (amount != null) {
      budgetProvider.setBudget(amount);
    }
  }
}

class _SummaryLabel extends StatelessWidget {
  final String label;
  final Widget value;
  final Color color;

  const _SummaryLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cardTitle),
        const SizedBox(height: AppSpacing.s4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: value,
        ),
      ],
    );
  }
}
