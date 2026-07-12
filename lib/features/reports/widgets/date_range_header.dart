import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
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
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 16.0, top: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(LucideIcons.x, color: theme.colorScheme.onSurfaceVariant),
                onPressed: onClose,
              ),
              Text(
                'Select Date',
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }
}
