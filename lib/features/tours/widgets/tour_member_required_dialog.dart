import 'package:flutter/material.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourMemberRequiredDialog extends StatelessWidget {
  final String tourId;

  const TourMemberRequiredDialog({super.key, required this.tourId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      backgroundColor: theme.cardColor,
      title: Text(
        context.translate('members_required_title'),
        style: AppTextStyles.dialogTitle.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        context.translate('need_at_least_2_members'),
        style: AppTextStyles.body.copyWith(
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
            child: Text(
              context.translate('cancel_button'),
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TourMemberManagementScreen(tourId: tourId),
              ),
            );
          },
          child: Text(
            context.translate('add_members_btn'),
            style: TextStyle(
              color: AppColors.activeGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
