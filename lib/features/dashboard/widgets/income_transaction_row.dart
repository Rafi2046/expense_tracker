import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class IncomeTransactionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget amount;
  final String status;
  final VoidCallback? onTap;

  const IncomeTransactionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.p12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                : AppColors.dividerColor,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                    : const Color(0xFFF3F5F4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.buttonColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.s12),
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
                    style: AppTextStyles.label.copyWith(color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                amount,
                const SizedBox(height: AppSpacing.s4),
                Text(
                  context.translate(status).toUpperCase(),
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                    fontFamily: TextStyle().fontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
