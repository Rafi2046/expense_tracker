import 'package:flutter/material.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

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
        'Members Required',
        style: AppTextStyles.dialogTitle.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        'You need at least 2 members in the tour to add expenses or settle up.',
        style: AppTextStyles.body.copyWith(
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
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
          child: const Text(
            'Add Members',
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
