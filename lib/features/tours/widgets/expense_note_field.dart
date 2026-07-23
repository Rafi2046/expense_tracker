import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
        hintText: context.translate('note_hint'),
        hintStyle: AppTextStyles.bodyBold.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p16,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.p4),
          child: Icon(
            LucideIcons.stickyNote,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF334155)
                : const Color(0xFFE5E7EB),
            width: AppSpacing.w1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          borderSide: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF334155)
                : const Color(0xFFE5E7EB),
            width: AppSpacing.w1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          borderSide: const BorderSide(
            color: Color(0xFF2EBD85),
            width: 1.5,
          ),
        ),
        isDense: true,
      ),
    );
  }
}
