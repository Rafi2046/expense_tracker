import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class SettingsTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType keyboardType;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.black54),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? theme.cardColor : const Color(0xFFF5F6F8),
            prefixIcon: Icon(
              prefixIcon,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 18,
            ),
            hintText: hintText,
            hintStyle: AppTextStyles.body.copyWith(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
