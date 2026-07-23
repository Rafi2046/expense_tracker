import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_stat_card.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DashboardStatsRow extends StatelessWidget {
  final bool isLoading;
  final String incomeTitle;
  final String expenseTitle;
  final double calendarMonthIncome;
  final double calendarMonthExpense;
  final bool isCalendarIncomeTrendGood;
  final bool isCalendarExpenseTrendGood;
  final String toReceiveTitle;
  final String toGiveTitle;
  final double totalToReceive;
  final double totalToGive;
  final int toReceivePendingCount;
  final int toGivePendingCount;
  final String pendingLabel;
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;
  final VoidCallback onToReceiveTap;
  final VoidCallback onToGiveTap;

  const DashboardStatsRow({
    super.key,
    required this.isLoading,
    required this.incomeTitle,
    required this.expenseTitle,
    required this.calendarMonthIncome,
    required this.calendarMonthExpense,
    required this.isCalendarIncomeTrendGood,
    required this.isCalendarExpenseTrendGood,
    required this.toReceiveTitle,
    required this.toGiveTitle,
    required this.totalToReceive,
    required this.totalToGive,
    required this.toReceivePendingCount,
    required this.toGivePendingCount,
    required this.pendingLabel,
    required this.onIncomeTap,
    required this.onExpenseTap,
    required this.onToReceiveTap,
    required this.onToGiveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Skeletonizer(
          enabled: isLoading,
          child: Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: incomeTitle,
                  value: PrivacyMaskedText(
                    amount: calendarMonthIncome,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      color: AppColors.activeGreen),
                  ),
                  isPositive: isCalendarIncomeTrendGood,
                  isTrend: false,
                  onTap: onIncomeTap,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: DashboardStatCard(
                  title: expenseTitle,
                  value: PrivacyMaskedText(
                    amount: calendarMonthExpense,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      color: AppColors.activeRed),
                  ),
                  isPositive: isCalendarExpenseTrendGood,
                  isTrend: false,
                  onTap: onExpenseTap,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Skeletonizer(
          enabled: isLoading,
          child: Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: toReceiveTitle,
                  value: PrivacyMaskedText(
                    amount: totalToReceive,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      color: AppColors.activeGreen),
                  ),
                  statusText: Text(
                    '$toReceivePendingCount $pendingLabel',
                    style: AppTextStyles.caption.copyWith(
                    ),
                  ),
                  isPositive: true,
                  isTrend: false,
                  onTap: onToReceiveTap,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: DashboardStatCard(
                  title: toGiveTitle,
                  value: PrivacyMaskedText(
                    amount: totalToGive,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      color: AppColors.activeRed),
                  ),
                  statusText: Text(
                    '$toGivePendingCount $pendingLabel',
                    style: AppTextStyles.caption.copyWith(
                    ),
                  ),
                  isPositive: false,
                  isTrend: false,
                  onTap: onToGiveTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
