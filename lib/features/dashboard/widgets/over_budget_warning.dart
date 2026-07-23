import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OverBudgetWarning extends StatelessWidget {
  final double excessAmount;

  const OverBudgetWarning({super.key, required this.excessAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p8,
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
            LucideIcons.alertTriangle,
            color: AppColors.activeRed,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.cardStatusText.copyWith(
                  color: AppColors.activeRed,
                ),
                children: [
                  const TextSpan(text: 'You\'ve exceeded your monthly budget by '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: PrivacyMaskedText(
                      amount: excessAmount,
                      style: AppTextStyles.cardStatusText.copyWith(
                        color: AppColors.activeRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
