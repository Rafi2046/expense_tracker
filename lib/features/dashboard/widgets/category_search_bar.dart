import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class CategorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Color activeThemeColor;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const CategorySearchBar({
    super.key,
    required this.controller,
    required this.activeThemeColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      style: GoogleFonts.workSans(
        fontSize: AppFontSizes.size15,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Search Category...',
        hintStyle: GoogleFonts.workSans(
          fontSize: AppFontSizes.size15,
          color: isDark ? Colors.white38 : Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          LucideIcons.search,
          color: isDark ? Colors.white38 : Colors.grey.shade400,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
            : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.15)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.15)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: activeThemeColor, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
