import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DataIntegrityWarning extends StatelessWidget {
  const DataIntegrityWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
      child: Row(
        children: [
          Icon(
            LucideIcons.lightbulb,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 16,
          ),
          const SizedBox(width: AppSpacing.w8),
          Flexible(
            child: Text(
              'Add buddies manually for offline tracking, or skip this and share the invite code later for real-time syncing!',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: AppFontSizes.size12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
