import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CalculatorInfoCard extends StatelessWidget {
  final String title;
  final List<CalculatorInfoItem> items;
  final Color themeColor;

  const CalculatorInfoCard({
    super.key,
    required this.title,
    required this.items,
    required this.themeColor,
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
          const SizedBox(height: AppSpacing.s12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.calculatorLabel.copyWith(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      item.description,
                      style: AppTextStyles.profileCardSubtitle.copyWith(color: isDark ? Colors.grey.shade400 : null),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class CalculatorInfoItem {
  final String label;
  final String description;

  const CalculatorInfoItem({
    required this.label,
    required this.description,
  });
}
