import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryListTile extends StatelessWidget {
  final String categoryName;
  final Color themeColor;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const CategoryListTile({
    super.key,
    required this.categoryName,
    required this.themeColor,
    required this.isDark,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF0F0F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.tag, color: themeColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFontSizes.size15,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (onEdit != null)
            IconButton(
              icon: Icon(
                LucideIcons.edit,
                color: isDark
                    ? Colors.grey.shade500
                    : Colors.grey.shade400,
                size: 20,
              ),
              onPressed: onEdit,
            ),
          IconButton(
            icon: Icon(
              LucideIcons.trash,
              color: isDark
                  ? Colors.grey.shade500
                  : Colors.grey.shade400,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
