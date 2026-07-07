import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CalculatorTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;

  const CalculatorTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.prefix,
    this.suffix,
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
          style: AppTextStyles.calculatorLabel.copyWith(color: isDark ? Colors.grey.shade400 : null),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1), width: 1.0),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.calculatorInputText.copyWith(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.textFieldHint.copyWith(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: prefix,
              suffixIcon: suffix,
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
          ),
        ),
      ],
    );
  }
}
