import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';

class OverBudgetWarning extends StatelessWidget {
  final double excessAmount;

  const OverBudgetWarning({super.key, required this.excessAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p10,
      ),
      decoration: BoxDecoration(
        color: AppColors.activeRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.br8),
        border: Border.all(
          color: AppColors.activeRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.activeRed,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              'You\'ve exceeded your monthly budget by ${context.formatAmount(excessAmount)}',
              style: AppTextStyles.cardStatusText.copyWith(
                color: AppColors.activeRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
