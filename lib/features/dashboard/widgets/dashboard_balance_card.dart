import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_stat_card.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DashboardBalanceCard extends StatelessWidget {
  final bool isLoading;
  final String cashBankTitle;
  final String totalBalanceLabel;
  final double totalBalance;
  final String reportsTitle;
  final String reportsLabel;
  final VoidCallback onCashBankTap;
  final VoidCallback onReportsTap;

  const DashboardBalanceCard({
    super.key,
    required this.isLoading,
    required this.cashBankTitle,
    required this.totalBalanceLabel,
    required this.totalBalance,
    required this.reportsTitle,
    required this.reportsLabel,
    required this.onCashBankTap,
    required this.onReportsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: Row(
        children: [
          Expanded(
            child: DashboardStatCard(
              title: cashBankTitle,
              value: Text(
                totalBalanceLabel,
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: AppColors.activeGreen),
              ),
              statusText: PrivacyMaskedText(
                amount: totalBalance,
                style: AppTextStyles.caption.copyWith(
                ),
              ),
              isPositive: true,
              isTrend: false,
              onTap: onCashBankTap,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: DashboardStatCard(
              title: reportsTitle,
              value: Text(
                reportsLabel,
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: AppColors.activeGreen),
              ),
              isPositive: true,
              isTrend: false,
              onTap: onReportsTap,
            ),
          ),
        ],
      ),
    );
  }
}
