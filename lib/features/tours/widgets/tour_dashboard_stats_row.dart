import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TourDashboardStatsRow extends StatelessWidget {
  final int expenseCount;
  final VoidCallback? onAddExpense;

  const TourDashboardStatsRow({
    super.key,
    required this.expenseCount,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.p8, bottom: AppSpacing.p12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                context.translate('expenses_count'),
                style: AppTextStyles.h2.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                ),
                child: Text(
                  '($expenseCount)',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          if (onAddExpense != null)
            TextButton.icon(
              onPressed: onAddExpense,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(
                context.translate('add_expense_fab'),
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.activeGreen,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                  side: BorderSide(
                    color: AppColors.activeGreen.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
