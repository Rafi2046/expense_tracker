import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/financial_health_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_daily_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_weekly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_monthly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_quarterly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_summary_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/time_frame_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IncomeInsightsScreen extends StatefulWidget {
  const IncomeInsightsScreen({super.key});

  @override
  State<IncomeInsightsScreen> createState() => _IncomeInsightsScreenState();
}

class _IncomeInsightsScreenState extends State<IncomeInsightsScreen> {
  String _selectedTimeFrame = 'Monthly';
  final List<String> _timeFrames = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  Widget _buildSummaryCard(IncomeAnalyticsProvider analytics) {
    switch (_selectedTimeFrame) {
      case 'Daily':
        final change = analytics.dailyPercentageChange;
        final isPositive = change >= 0;
        final sign = isPositive ? '+' : '';
        return IncomeSummaryCard(
          label: 'Total Daily Income',
          amount: '${context.currencySymbol}${analytics.todayIncome.toStringAsFixed(2)}',
          showDivider: true,
          bottomContent: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vs Yesterday',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.loginSubTitle
                      : Colors.white70,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? Symbols.trending_up : Symbols.trending_down,
                    color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$sign${change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
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
          amount: '${context.currencySymbol}${analytics.currentWeekIncome.toStringAsFixed(2)}',
          showDivider: true,
          bottomContent: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg. Daily',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.loginSubTitle
                          : Colors.white70,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  Text(
                    '${context.currencySymbol}${avgDaily.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vs Last Week',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.loginSubTitle
                          : Colors.white70,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Symbols.trending_up : Symbols.trending_down,
                        color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$sign${change.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? AppColors.activeGreen : AppColors.activeRed,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
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
          amount: '${context.currencySymbol}${quarterlyIncome.toStringAsFixed(2)}',
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.loginSubTitle
                          : Colors.white70,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  Text(
                    '${context.currencySymbol}${projectedYearEnd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
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
          amount: '${isPositive ? '+' : ''}${context.currencySymbol}${analytics.currentMonthIncome.toStringAsFixed(2)}',
          percentageText: '$sign${change.toStringAsFixed(1)}%',
          compareText: 'vs. last month',
        );
    }
  }

  Widget _buildTimeFrameContent() {
    switch (_selectedTimeFrame) {
      case 'Daily':
        return const IncomeDailySection();
      case 'Weekly':
        return const IncomeWeeklySection();
      case 'Quarterly':
        return const IncomeQuarterlySection();
      case 'Monthly':
      default:
        return const IncomeMonthlySection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analytics = context.watch<IncomeAnalyticsProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: theme.appBarTheme.iconTheme?.color),
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
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              // Timeframe-dependent content
              _buildTimeFrameContent(),
              const SizedBox(height: 24),

              // Bottom Banner
              const FinancialHealthBanner(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
