import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class ProfileInfoBanner extends StatelessWidget {
  const ProfileInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
            : const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.info,
            color: theme.textTheme.bodySmall?.color,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              'You can also create & manage multiple profiles from the homepage later.',
              style: AppTextStyles.label.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
          ),
        ],
      ),
    );
  }
}
