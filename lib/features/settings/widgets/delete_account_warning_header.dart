import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DeleteAccountWarningHeader extends StatelessWidget {
  const DeleteAccountWarningHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.red.withValues(alpha: 0.15)
                : const Color(0xFFFDE8E8),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.trash,
            color: AppColors.activeRed,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          context.translate('delete_account'),
          style: AppTextStyles.h1.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.s12),
      ],
    );
  }
}
