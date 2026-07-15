import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;
  final String currencySymbol;
  final bool isDark;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.themeColor,
    required this.currencySymbol,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260,
        child: TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFontSizes.size36,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
          decoration: InputDecoration(
            prefixText: '$currencySymbol ',
            prefixStyle: TextStyle(
              fontSize: AppFontSizes.size32,
              fontWeight: FontWeight.bold,
              color: themeColor.withValues(alpha: 0.6),
            ),
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: AppFontSizes.size36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
