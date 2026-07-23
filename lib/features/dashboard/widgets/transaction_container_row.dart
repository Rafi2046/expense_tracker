import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TransactionContainerRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget amount;
  final String? subAmountLabel;
  final VoidCallback? onTap;

  const TransactionContainerRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.subAmountLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                    : const Color(0xFFF3F5F4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.buttonColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                amount,
                if (subAmountLabel != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    subAmountLabel!,
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
