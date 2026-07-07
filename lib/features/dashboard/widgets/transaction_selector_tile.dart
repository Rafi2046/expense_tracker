import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionSelectorTile extends StatelessWidget {
  final IconData leadingIcon;
  final String labelText;
  final String valueText;
  final bool isValueSelected;
  final Color themeColor;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const TransactionSelectorTile({
    super.key,
    required this.leadingIcon,
    required this.labelText,
    required this.valueText,
    required this.isValueSelected,
    required this.themeColor,
    required this.trailingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Icon Badge ──
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(leadingIcon, color: themeColor, size: 19),
            ),
            const SizedBox(width: 14),

            // ── Label + Value (floating label style) ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: GoogleFonts.workSans(
                      fontSize: 10.5,
                      color: isDark
                          ? Colors.white38
                          : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    valueText,
                    style: GoogleFonts.workSans(
                      fontSize: 14.5,
                      fontWeight: isValueSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isValueSelected
                          ? theme.colorScheme.onSurface
                          : (isDark ? Colors.white24 : Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            ),

            // ── Trailing Icon ──
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                trailingIcon,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
