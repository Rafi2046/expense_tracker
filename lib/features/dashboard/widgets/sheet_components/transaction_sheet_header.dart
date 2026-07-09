import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
            // ── Title + Subtitle ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size12,
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
