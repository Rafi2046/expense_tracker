import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/financial_health_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_daily_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_weekly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_monthly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_quarterly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_summary_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/time_frame_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeInsightsScreen extends StatefulWidget {
  const IncomeInsightsScreen({super.key});

  @override
  State<IncomeInsightsScreen> createState() => _IncomeInsightsScreenState();
}

class _IncomeInsightsScreenState extends State<IncomeInsightsScreen> {
  String _selectedTimeFrame = 'Monthly';
  static bool _localMasked = false;
  final List<String> _timeFrames = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  Widget _buildSummaryCard(IncomeAnalyticsProvider analytics) {
    switch (_selectedTimeFrame) {
      case 'Daily':
        final change = analytics.dailyPercentageChange;
        final isPositive = change >= 0;
        final sign = isPositive ? '+' : '';
        return IncomeSummaryCard(
          label: 'Total Daily Income',
          amount: PrivacyMaskedText(
            amount: analytics.todayIncome,
            style: AppTextStyles.summaryCardValue,
            isMasked: _localMasked,
          ),
          isMasked: _localMasked,
          onToggleMask: () => setState(() => _localMasked = !_localMasked),
          showDivider: true,
          bottomContent: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vs Yesterday',
style: AppTextStyles.bodySmall
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                    color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$sign${change.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: isPositive ? AppColors.activeGreen : AppColors.activeRed),
                  ),
                ],
              ),
            ],
          ),
        );
      case 'Weekly':
        final avgDaily = analytics.currentWeekIncome / 7.0;
        final change = analytics.weeklyPercentageChange;
        final isPositive = change >= 0;
        final sign = isPositive ? '+' : '';
        return IncomeSummaryCard(
          label: 'Total Weekly Income',
          amount: PrivacyMaskedText(
            amount: analytics.currentWeekIncome,
            style: AppTextStyles.summaryCardValue,
            isMasked: _localMasked,
          ),
          isMasked: _localMasked,
          onToggleMask: () => setState(() => _localMasked = !_localMasked),
          showDivider: true,
          bottomContent: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg. Daily',
                    style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.light ? AppColors.loginSubTitle : Colors.white70),
                  ),
                  PrivacyMaskedText(
                    amount: avgDaily,
                    isMasked: _localMasked,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vs Last Week',
                    style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.light ? AppColors.loginSubTitle : Colors.white70),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$sign${change.toStringAsFixed(1)}%',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: isPositive ? AppColors.activeGreen : AppColors.activeRed),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      case 'Quarterly':
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
          label: 'Total Quarterly Income',
          amount: PrivacyMaskedText(
            amount: quarterlyIncome,
            style: AppTextStyles.summaryCardValue,
            isMasked: _localMasked,
          ),
          isMasked: _localMasked,
          onToggleMask: () => setState(() => _localMasked = !_localMasked),
          percentageText: '$sign${change.toStringAsFixed(1)}% vs $prevQStr',
          showDivider: true,
          bottomContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Projected Year End',
                    style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).brightness == Brightness.light ? AppColors.loginSubTitle : Colors.white70),
                  ),
                  PrivacyMaskedText(
                    amount: projectedYearEnd,
                    isMasked: _localMasked,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(context).brightness == Brightness.light
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
      case 'Monthly':
      default:
        final change = analytics.monthlyPercentageChange;
        final isPositive = change >= 0;
        final sign = isPositive ? '+' : '';
        return IncomeSummaryCard(
          label: 'Total Monthly Income',
          amount: PrivacyMaskedText(
            amount: analytics.currentMonthIncome,
            style: AppTextStyles.summaryCardValue,
            isMasked: _localMasked,
          ),
          isMasked: _localMasked,
          onToggleMask: () => setState(() => _localMasked = !_localMasked),
          percentageText: '$sign${change.toStringAsFixed(1)}%',
          compareText: 'vs. last month',
        );
    }
  }

  Widget _buildTimeFrameContent() {
    switch (_selectedTimeFrame) {
      case 'Daily':
        return IncomeDailySection(isMasked: _localMasked);
      case 'Weekly':
        return IncomeWeeklySection(isMasked: _localMasked);
      case 'Quarterly':
        return IncomeQuarterlySection(isMasked: _localMasked);
      case 'Monthly':
      default:
        return IncomeMonthlySection(isMasked: _localMasked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analytics = context.watch<IncomeAnalyticsProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Income Insights',
          style: AppTextStyles.insightsHeaderTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerTheme.color, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              _buildSummaryCard(analytics),
              const SizedBox(height: 16),

              // Timeframe selector
              TimeFrameSelector(
                timeFrames: _timeFrames,
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: (tf) {
                  setState(() {
                    _selectedTimeFrame = tf;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Timeframe-dependent content
              _buildTimeFrameContent(),
              const SizedBox(height: 16),

              // Bottom Banner
              const FinancialHealthBanner(),
              SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
