import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class AddNewCategoryTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const AddNewCategoryTile({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        icon: Icon(LucideIcons.plus, size: 18),
        label: Text(context.translate('add_new_category')),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                : Colors.grey.shade200,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.size14,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
