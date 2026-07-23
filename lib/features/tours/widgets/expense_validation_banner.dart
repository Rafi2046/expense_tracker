import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class ExpenseValidationBanner extends StatelessWidget {
  final String? error;

  const ExpenseValidationBanner({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p12,
              vertical: AppSpacing.p8,
            ),
            decoration: BoxDecoration(
              color: AppColors.activeRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.alertCircle, size: 16, color: AppColors.activeRed.withValues(alpha: 0.8)),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    error!,
                    style: AppTextStyles.label.copyWith(color: AppColors.activeRed),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
      ],
    );
  }
}
