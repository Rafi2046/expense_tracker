import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourDescriptionField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;

  const TourDescriptionField({
    super.key,
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.12);
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: context.translate('description_optional'),
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        hintText: context.translate('description_hint'),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: AppTextStyles.reportTileTitle.copyWith(
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
