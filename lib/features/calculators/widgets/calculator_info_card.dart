import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.profileCardTitle,
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: AppTextStyles.profileCardSubtitle,
                    ),
                    const SizedBox(height: 4),
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
