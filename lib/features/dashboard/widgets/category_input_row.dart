import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryInputRow extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onAddPressed;

  const CategoryInputRow({
    super.key,
    required this.controller,
    required this.themeColor,
    this.onSubmitted,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: AppFontSizes.size15,
              ),
              decoration: InputDecoration(
                hintText: 'Enter category name, then tap +',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontSize: AppFontSizes.size14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: onSubmitted,
              onEditingComplete: onAddPressed,
            ),
          ),
          IconButton(
            onPressed: onAddPressed,
            icon: Icon(LucideIcons.plusCircle, color: themeColor, size: 30),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }
}
