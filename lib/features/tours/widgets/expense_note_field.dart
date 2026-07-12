import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class ExpenseNoteField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;

  const ExpenseNoteField({
    super.key,
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      style: AppTextStyles.bodyBold.copyWith(
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Add a note...',
        hintStyle: AppTextStyles.bodyBold.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            LucideIcons.stickyNote,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
