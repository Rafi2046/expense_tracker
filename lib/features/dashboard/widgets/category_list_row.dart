import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class CategoryListRow extends StatelessWidget {
  final String categoryName;
  final Color themeColor;
  final bool isSelected;
  final bool showSelection;
  final bool showLeadingIcon;
  final VoidCallback? onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const CategoryListRow({
    super.key,
    required this.categoryName,
    required this.themeColor,
    this.isSelected = false,
    this.showSelection = false,
    this.showLeadingIcon = false,
    this.onTap,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.p12,
                horizontal: AppSpacing.p8,
              ),
              child: Row(
                children: [
                  if (showLeadingIcon) ...[
                    Icon(LucideIcons.tag, color: themeColor),
                    const SizedBox(width: AppSpacing.s12),
                  ],
                  Expanded(
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: theme.colorScheme.onSurface),
                    ),
                  ),
                  if (showSelection) ...[
                    const SizedBox(width: AppSpacing.s8),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? themeColor : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                          width: isSelected ? 6 : 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s4),
        if (onEdit != null)
          IconButton(
            icon: Icon(
              LucideIcons.edit,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 20,
            ),
            onPressed: onEdit,
          ),
        IconButton(
          icon: Icon(
            LucideIcons.trash,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            size: 20,
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
