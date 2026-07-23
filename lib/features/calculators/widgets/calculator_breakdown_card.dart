import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_legend_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CalculatorBreakdownCard extends StatelessWidget {
  final String title;
  final String label1;
  final Color color1;
  final double ratio1;
  final String label2;
  final Color color2;
  final double ratio2;

  const CalculatorBreakdownCard({
    super.key,
    required this.title,
    required this.label1,
    required this.color1,
    required this.ratio1,
    required this.label2,
    required this.color2,
    required this.ratio2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.profileCardTitle.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.s16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            child: Container(
              height: 12,
              width: double.infinity,
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F0F0),
              child: Row(
                children: [
                  if (ratio1 > 0)
                    Expanded(
                      flex: (ratio1 * 100).round(),
                      child: Container(color: color1),
                    ),
                  if (ratio2 > 0)
                    Expanded(
                      flex: (ratio2 * 100).round(),
                      child: Container(color: color2),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CalculatorLegendItem(label: label1, color: color1, ratio: ratio1),
              CalculatorLegendItem(label: label2, color: color2, ratio: ratio2),
            ],
          ),
        ],
      ),
    );
  }
}
