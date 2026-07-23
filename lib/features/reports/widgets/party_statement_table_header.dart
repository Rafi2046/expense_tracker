import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
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
                    color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  '$entryCount entries',
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
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
                    color: AppColors.activeGreen),
                ),
                const SizedBox(height: AppSpacing.s4),
                PrivacyMaskedText(
                  amount: receiveTotal,
                  isMasked: isMasked,
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    color: AppColors.activeGreen,
                    fontWeight: FontWeight.w600),
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
                    color: AppColors.activeRed),
                ),
                const SizedBox(height: AppSpacing.s4),
                PrivacyMaskedText(
                  amount: giveTotal,
                  isMasked: isMasked,
                  style: AppTextStyles.reportTransactionSubtitle.copyWith(
                    color: AppColors.activeRed,
                    fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
