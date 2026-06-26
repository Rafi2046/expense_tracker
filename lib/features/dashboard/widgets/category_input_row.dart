import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
              style: GoogleFonts.workSans(
                color: theme.colorScheme.onSurface,
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                hintText: 'Add new category...',
                hintStyle: GoogleFonts.workSans(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(Symbols.add_circle, color: themeColor, size: 28),
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}
