import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourNameField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;

  const TourNameField({
    super.key,
    required this.theme,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: context.translate('tour_name_field'),
          hintText: context.translate('tour_name_hint'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: AppTextStyles.reportTileTitle.copyWith(
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
