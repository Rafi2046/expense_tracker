import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CalculatorResultCard extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradientColors;
  final Color shadowColor;
  final List<CalculatorResultItem> subItems;
  final CalculatorResultItem? bottomItem;

  const CalculatorResultCard({
    super.key,
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.shadowColor,
    required this.subItems,
    this.bottomItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.calculatorResultLabel,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: AppTextStyles.calculatorResultAmount,
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppSpacing.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: subItems,
          ),
          if (bottomItem != null) ...[
            const SizedBox(height: AppSpacing.s16),
            bottomItem!,
          ],
        ],
      ),
    );
  }
}
