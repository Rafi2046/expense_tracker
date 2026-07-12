import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DateRangeDisplay extends StatelessWidget {
  final String rangeText;
  final VoidCallback onEditTap;

  const DateRangeDisplay({
    super.key,
    required this.rangeText,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                rangeText,
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(LucideIcons.edit, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 18),
                onPressed: onEditTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
