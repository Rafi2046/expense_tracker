import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.size14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppFontSizes.size11,
                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                amount,
                if (subAmountLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subAmountLabel!,
                    style: TextStyle(
                      fontSize: AppFontSizes.size11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontFamily: GoogleFonts.workSans().fontFamily,
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
