import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class IncomeTrendInfoDialog extends StatelessWidget {
  const IncomeTrendInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r16)),
      backgroundColor: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  color: AppColors.buttonColor,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(context.translate('income_trend_chart_title'), style: AppTextStyles.dialogTitle),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              context.translate('income_trend_chart_desc'),
              style: AppTextStyles.dialogBody,
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.p4, right: AppSpacing.p8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.buttonColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.translate('income_trend_highlighted_bars_desc'),
                    style: AppTextStyles.dialogBulletText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.p4, right: AppSpacing.p8),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.activeGreen.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.translate('income_trend_lighter_bars_desc'),
                    style: AppTextStyles.dialogBulletText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p16,
                    vertical: AppSpacing.p8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                ),
                child: Text(context.translate('close'), style: AppTextStyles.dialogCloseButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
