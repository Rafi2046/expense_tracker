import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NoteInputField extends StatelessWidget {
  final TextEditingController controller;
  final Color focusColor;
  final bool isDark;

  const NoteInputField({
    super.key,
    required this.controller,
    required this.focusColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: 2,
      style: TextStyle(
        fontSize: AppFontSizes.size15,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: context.translate('add_note_detail_hint'),
        hintStyle: TextStyle(
          fontSize: AppFontSizes.size15,
          color: isDark ? Colors.white30 : Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          LucideIcons.notepadText,
          color: isDark ? Colors.white30 : Colors.grey.shade400,
          size: 22,
        ),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerTheme.color ?? Colors.grey.shade100,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerTheme.color ?? Colors.grey.shade100,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: focusColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
