import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/utils/category_utils.dart';

class CategoryDetailCard extends StatelessWidget {
  final String category;

  const CategoryDetailCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catIcon = CategoryUtils.getIcon(category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            catIcon,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 14),
          Text(
            category,
            style: TextStyle(
              fontSize: AppFontSizes.size15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
