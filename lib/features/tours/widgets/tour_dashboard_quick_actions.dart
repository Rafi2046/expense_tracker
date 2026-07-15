import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourDashboardQuickActions extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onAddExpense;

  const TourDashboardQuickActions({
    super.key,
    required this.isCompleted,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 60),
      child: FloatingActionButton.extended(
        heroTag: 'tour_dashboard_fab',
        onPressed: onAddExpense,
        backgroundColor: isCompleted
            ? AppColors.activeGreen.withValues(alpha: 0.35)
            : AppColors.activeGreen,
        icon: Icon(LucideIcons.plus,
            color: AppColors.white.withValues(alpha: isCompleted ? 0.5 : 1),
            size: 20),
        label: Text(
          context.translate('add_expense_fab'),
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.white.withValues(alpha: isCompleted ? 0.5 : 1),
          ),
        ),
        elevation: isCompleted ? 0 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
        ),
      ),
    );
  }
}
