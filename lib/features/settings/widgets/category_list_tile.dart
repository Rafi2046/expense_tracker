import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



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
      margin: const EdgeInsets.only(bottom: AppSpacing.p8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
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
                vertical: AppSpacing.p12,
                horizontal: AppSpacing.p8,
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.tag, color: themeColor),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
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
