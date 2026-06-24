import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReportStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final bool isPositive;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.reportStatLabel,
          ),
          const SizedBox(height: 4),
          Text(
            '$currencySymbol ${amount.toStringAsFixed(0)}',
            style: AppTextStyles.reportStatValue.copyWith(
              color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
            ),
          ),
        ],
      ),
    );
  }
}
