import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      style: GoogleFonts.workSans(
        fontSize: 15,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Add a note/detail (optional)...',
        hintStyle: GoogleFonts.workSans(
          fontSize: 15,
          color: isDark ? Colors.white30 : Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          Symbols.notes_rounded,
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
