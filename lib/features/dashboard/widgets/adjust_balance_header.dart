import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class AdjustBalanceHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const AdjustBalanceHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Center(
          child: Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.x,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
      ],
    );
  }
}
