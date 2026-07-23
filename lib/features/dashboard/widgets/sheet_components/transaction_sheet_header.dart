import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TransactionSheetHeader extends StatelessWidget {
  final bool isEditing;
  final bool isIncome;
  final VoidCallback onClose;

  const TransactionSheetHeader({
    super.key,
    required this.isEditing,
    required this.isIncome,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = isEditing
        ? (isIncome ? context.translate('edit_income') : context.translate('edit_expense'))
        : (isIncome ? context.translate('add_income') : context.translate('add_expense'));
    final subtitle = isIncome ? context.translate('record_your_earnings') : context.translate('track_your_spending');

    return Column(
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        Row(
          children: [
            // ── Title + Subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subtitle,
                    style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white38 : Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // ── Close Button ──
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.p8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                ),
                child: Icon(
                  LucideIcons.x,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
