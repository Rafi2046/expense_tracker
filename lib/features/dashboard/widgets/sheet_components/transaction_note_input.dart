import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TransactionNoteInput extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;

  const TransactionNoteInput({
    super.key,
    required this.controller,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: 2,
      style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: context.translate('note_hint'),
        hintStyle: AppTextStyles.body.copyWith(color: isDark ? Colors.white24 : Colors.grey.shade400),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.p12, right: AppSpacing.p8, bottom: AppSpacing.p12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Icon(
              LucideIcons.notepadText,
              color: themeColor.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 60, minHeight: 38),
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
            : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.p16, horizontal: AppSpacing.p16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          borderSide: BorderSide(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          borderSide: BorderSide(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
          borderSide: BorderSide(
            color: themeColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
