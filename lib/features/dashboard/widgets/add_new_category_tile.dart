import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
        label: const Text('Add New Category'),
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
          textStyle: GoogleFonts.workSans(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.size14,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
