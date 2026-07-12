import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';

class PartyStatementTableHeader extends StatelessWidget {
  final int entryCount;
  final double receiveTotal;
  final double giveTotal;
  final bool isMasked;

  const PartyStatementTableHeader({
    super.key,
    required this.entryCount,
    required this.receiveTotal,
    required this.giveTotal,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$entryCount entries',
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    fontSize: AppFontSizes.size11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Debit',
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: AppColors.activeGreen,
                  ),
                ),
                const SizedBox(height: 4),
                PrivacyMaskedText(
                  amount: receiveTotal,
                  isMasked: isMasked,
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    color: AppColors.activeGreen,
                    fontSize: AppFontSizes.size11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Credit',
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: AppColors.activeRed,
                  ),
                ),
                const SizedBox(height: 4),
                PrivacyMaskedText(
                  amount: giveTotal,
                  isMasked: isMasked,
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    color: AppColors.activeRed,
                    fontSize: AppFontSizes.size11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
