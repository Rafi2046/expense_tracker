import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CalculatorResultItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isCenter;

  const CalculatorResultItem({
    super.key,
    required this.title,
    required this.value,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.calculatorResultLabel,
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: isCenter
              ? AppTextStyles.h1
              : AppTextStyles.calculatorResultAmount,
        ),
      ],
    );
  }
}
