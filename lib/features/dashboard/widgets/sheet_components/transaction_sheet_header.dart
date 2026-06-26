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

    return Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEditing
                  ? (isIncome ? 'Edit Income' : 'Edit Expense')
                  : (isIncome ? 'Add Income' : 'Add Expense'),
              style: GoogleFonts.workSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Symbols.close,
                  size: 20,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
