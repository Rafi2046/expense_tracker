import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class ExpenseLateJoinerBanner extends StatelessWidget {
  final ThemeData theme;
  final String names;
  final String dateText;

  const ExpenseLateJoinerBanner({
    super.key,
    required this.theme,
    required this.names,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.activeGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 14, color: AppColors.activeGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$names joined after $dateText — unchecked by default.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.activeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
