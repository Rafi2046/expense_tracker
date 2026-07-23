import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
            : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.cloud,
            color: isDark ? Colors.white38 : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              'Entry is synced successfully!',
              style: AppTextStyles.label.copyWith(color: isDark ? Colors.white60 : AppColors.textMuted,
                fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
