import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryListRow extends StatelessWidget {
  final String categoryName;
  final Color themeColor;
  final bool isSelected;
  final bool showSelection;
  final bool showLeadingIcon;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const CategoryListRow({
    super.key,
    required this.categoryName,
    required this.themeColor,
    this.isSelected = false,
    this.showSelection = false,
    this.showLeadingIcon = false,
    this.onTap,
    required this.onDelete,
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
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Row(
                children: [
                  if (showLeadingIcon) ...[
                    Icon(Icons.label_outline_rounded, color: themeColor),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (showSelection) ...[
                    const SizedBox(width: 8),
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
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(
            Icons.delete_outline_rounded,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            size: 20,
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
