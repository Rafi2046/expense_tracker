import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeSummaryRow extends StatelessWidget {
  final IncomeAnalyticsProvider analytics;
  final String selectedTimeFrame;
  final bool isMasked;
  final VoidCallback onToggleMask;

  const IncomeSummaryRow({
    super.key,
    required this.analytics,
    required this.selectedTimeFrame,
    required this.isMasked,
    required this.onToggleMask,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedTimeFrame) {
      case 'Daily':
        return _buildDaily(context);
      case 'Weekly':
        return _buildWeekly(context);
      case 'Quarterly':
        return _buildQuarterly(context);
      case 'Monthly':
      default:
        return _buildMonthly(context);
    }
  }

  Widget _buildDaily(BuildContext context) {
    final change = analytics.dailyPercentageChange;
    final isPositive = change >= 0;
    final sign = isPositive ? '+' : '';
    return IncomeSummaryCard(
      label: context.translate('total_daily_income'),
      amount: PrivacyMaskedText(
        amount: analytics.todayIncome,
        style: AppTextStyles.summaryCardValue,
        isMasked: isMasked,
      ),
      isMasked: isMasked,
      onToggleMask: onToggleMask,
      showDivider: true,
      bottomContent: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.translate('vs_yesterday'), style: AppTextStyles.bodySmall),
          Row(
            children: [
              Icon(
                isPositive
                    ? LucideIcons.trendingUp
                    : LucideIcons.trendingDown,
                color: isPositive
                    ? AppColors.activeGreen
                    : AppColors.activeRed,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$sign${change.toStringAsFixed(1)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPositive
                      ? AppColors.activeGreen
                      : AppColors.activeRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekly(BuildContext context) {
    final avgDaily = analytics.currentWeekIncome / 7.0;
    final change = analytics.weeklyPercentageChange;
    final isPositive = change >= 0;
    final sign = isPositive ? '+' : '';
    return IncomeSummaryCard(
      label: context.translate('total_weekly_income'),
      amount: PrivacyMaskedText(
        amount: analytics.currentWeekIncome,
        style: AppTextStyles.summaryCardValue,
        isMasked: isMasked,
      ),
      isMasked: isMasked,
      onToggleMask: onToggleMask,
      showDivider: true,
      bottomContent: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('avg_daily'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.loginSubTitle
                      : Colors.white70,
                ),
              ),
              PrivacyMaskedText(
                amount: avgDaily,
                isMasked: isMasked,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('vs_last_week'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.loginSubTitle
                      : Colors.white70,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isPositive
                        ? LucideIcons.trendingUp
                        : LucideIcons.trendingDown,
                    color: isPositive
                        ? AppColors.activeGreen
                        : AppColors.activeRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$sign${change.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPositive
                          ? AppColors.activeGreen
                          : AppColors.activeRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterly(BuildContext context) {
    final q = ((DateTime.now().month - 1) ~/ 3) + 1;
    final prevQStr = q == 1 ? 'Q4' : 'Q${q - 1}';
    final change = analytics.quarterlyPercentageChange;
    final isPositive = change >= 0;
    final sign = isPositive ? '+' : '';
    final quarterlyIncome = analytics.currentQuarterIncome;
    final projectedYearEnd = quarterlyIncome * 4.0;
    final monthOfQuarter = (DateTime.now().month - 1) % 3 + 1;
    final dayOfMonth = DateTime.now().day;
    final progress = (monthOfQuarter - 1) / 3.0 + (dayOfMonth / 90.0);
    return IncomeSummaryCard(
      label: context.translate('total_quarterly_income'),
      amount: PrivacyMaskedText(
        amount: quarterlyIncome,
        style: AppTextStyles.summaryCardValue,
        isMasked: isMasked,
      ),
      isMasked: isMasked,
      onToggleMask: onToggleMask,
      percentageText: '$sign${change.toStringAsFixed(1)}% ${context.translate('vs')} $prevQStr',
      showDivider: true,
      bottomContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('projected_year_end'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.loginSubTitle
                      : Colors.white70,
                ),
              ),
              PrivacyMaskedText(
                amount: projectedYearEnd,
                isMasked: isMasked,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor:
                  Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFE0E0E0)
                  : Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.activeGreen,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthly(BuildContext context) {
    final change = analytics.monthlyPercentageChange;
    final isPositive = change >= 0;
    final sign = isPositive ? '+' : '';
    return IncomeSummaryCard(
      label: context.translate('total_monthly_income'),
      amount: PrivacyMaskedText(
        amount: analytics.currentMonthIncome,
        style: AppTextStyles.summaryCardValue,
        isMasked: isMasked,
      ),
      isMasked: isMasked,
      onToggleMask: onToggleMask,
      percentageText: '$sign${change.toStringAsFixed(1)}%',
      compareText: context.translate('vs_last_month'),
    );
  }
}
