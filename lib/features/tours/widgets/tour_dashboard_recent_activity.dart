import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TourDashboardRecentActivity extends StatelessWidget {
  const TourDashboardRecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.p4,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.noExpense, height: 140, width: 140),

            Text(
              context.translate('no_expenses_yet'),
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              context.translate('tap_to_add_first_expense'),
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
