import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CalculatorTypeSelector extends StatelessWidget {
  final String title1;
  final String title2;
  final bool isSelected1;
  final VoidCallback onTap1;
  final VoidCallback onTap2;

  const CalculatorTypeSelector({
    super.key,
    required this.title1,
    required this.title2,
    required this.isSelected1,
    required this.onTap1,
    required this.onTap2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    title1,
                    style: AppTextStyles.calculatorLabel.copyWith(
                      fontWeight: isSelected1 ? FontWeight.bold : FontWeight.w500,
                      color: isSelected1 ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isSelected1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isSelected1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    title2,
                    style: AppTextStyles.calculatorLabel.copyWith(
                      fontWeight: !isSelected1 ? FontWeight.bold : FontWeight.w500,
                      color: !isSelected1 ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
