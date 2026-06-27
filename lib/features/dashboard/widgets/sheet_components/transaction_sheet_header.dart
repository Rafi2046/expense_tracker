import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final accentColor = isIncome ? theme.primaryColor : const Color(0xFFDC3545);
    final title = isEditing
        ? (isIncome ? 'Edit Income' : 'Edit Expense')
        : (isIncome ? 'Add Income' : 'Add Expense');
    final subtitle = isIncome ? 'Record your earnings' : 'Track your spending';

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
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            // ── Accent icon badge ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                isIncome
                    ? Symbols.south_west_rounded
                    : Symbols.north_east_rounded,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // ── Title + Subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.workSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Close Button ──
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Symbols.close_rounded,
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
