import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


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
              context.translate('data_integrity_warning'),
              style: AppTextStyles.label.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
