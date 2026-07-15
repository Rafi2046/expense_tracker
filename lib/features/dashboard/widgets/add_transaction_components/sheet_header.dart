import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SheetHeader extends StatelessWidget {
  final bool isEditing;
  final bool isIncome;
  final VoidCallback onClose;

  const SheetHeader({
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
              style: TextStyle(
                fontSize: AppFontSizes.size20,
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
                  LucideIcons.x,
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
