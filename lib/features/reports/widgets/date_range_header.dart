import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DateRangeHeader extends StatelessWidget {
  final VoidCallback onClose;

  const DateRangeHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.p8),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.p12, right: AppSpacing.p16, top: AppSpacing.p8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(LucideIcons.x, color: theme.colorScheme.onSurfaceVariant),
                onPressed: onClose,
              ),
              Text(
                context.translate('select_date'),
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.w48),
            ],
          ),
        ),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }
}
