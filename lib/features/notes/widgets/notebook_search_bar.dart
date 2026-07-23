import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class NotebookSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isDark;

  const NotebookSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(
          color: theme.colorScheme.onSurface,
          fontFamily: GoogleFonts.workSans().fontFamily,
        ),
        decoration: InputDecoration(
          hintText: context.translate('search_notes_hint'),
          hintStyle: AppTextStyles.body.copyWith(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
            fontFamily: GoogleFonts.workSans().fontFamily,
          ),
          prefixIcon: Icon(LucideIcons.search, color: isDark ? Colors.grey.shade400 : Colors.grey.shade400, size: 20),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(LucideIcons.x, size: 18),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
