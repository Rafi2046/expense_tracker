import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

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
          labelText: 'Tour Name',
          hintText: 'e.g. Bali Trip 2026',
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
