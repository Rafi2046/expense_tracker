import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class LedgerBalanceHeader extends StatelessWidget {
  final String balance;
  final String trendPercentage;

  const LedgerBalanceHeader({
    super.key,
    required this.balance,
    required this.trendPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Label
        Text(
          context.translate('total_balance').toUpperCase(),
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: AppFontSizes.size11,
            color: AppColors.loginSubTitle.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),

        // Balance & Trend Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              balance,
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: AppFontSizes.size32,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trendPercentage,
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.activeGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
