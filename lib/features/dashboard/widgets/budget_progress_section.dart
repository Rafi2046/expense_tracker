import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class BudgetProgressSection extends StatelessWidget {
  final double percentage;
  final double spent;
  final double budget;

  const BudgetProgressSection({
    super.key,
    required this.percentage,
    required this.spent,
    required this.budget,
  });

  Color _progressColor() {
    if (percentage > 100) return AppColors.activeRed;
    if (percentage > 80) return const Color(0xFFF59E0B);
    return AppColors.activeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final clampedPercentage = percentage.clamp(0, 100);
    final color = _progressColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.br8),
          child: LinearProgressIndicator(
            value: clampedPercentage / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          context.translate('percent_used', namedArgs: {'percentage': percentage.toStringAsFixed(1)}),
          style: AppTextStyles.cardStatusText.copyWith(color: color),
        ),
      ],
    );
  }
}
