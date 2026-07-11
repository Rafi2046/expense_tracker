import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_breakdown_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_categories_breakdown_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_time_frame_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/expense_trend_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExpenseInsightsScreen extends StatefulWidget {
  const ExpenseInsightsScreen({super.key});

  @override
  State<ExpenseInsightsScreen> createState() => _ExpenseInsightsScreenState();
}

class _ExpenseInsightsScreenState extends State<ExpenseInsightsScreen> {
  String _selectedTimeFrame = 'Daily';
  static bool _localMasked = false;
  final List<String> _timeFrames = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseAnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Expense Insights',
          style: AppTextStyles.insightsHeaderTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _localMasked = !_localMasked);
            },
            icon: Icon(
              _localMasked ? LucideIcons.shield : LucideIcons.shieldOff,
              color: AppColors.notificationIcon,
              size: 26,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerTheme.color, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            16.0 + MediaQuery.of(context).padding.bottom + 80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpenseTimeFrameSelector(
                timeFrames: _timeFrames,
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: (tf) {
                  setState(() {
                    _selectedTimeFrame = tf;
                  });
                },
              ),
              const SizedBox(height: 20),

              if (_selectedTimeFrame == 'Daily')
                ExpenseTrendChartCard(
                  timeFrame: 'Daily',
                  title: 'Expense (Today)',
                  amount: PrivacyMaskedText(
                    amount: provider.todayExpense,
                    isMasked: _localMasked,
                    style: AppTextStyles.displayLarge.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  chartData: provider.dailyChartData,
                )
              else if (_selectedTimeFrame == 'Weekly')
                ExpenseTrendChartCard(
                  timeFrame: 'Weekly',
                  title: 'Expense (This Week)',
                  amount: PrivacyMaskedText(
                    amount: provider.currentWeekExpense,
                    isMasked: _localMasked,
                    style: AppTextStyles.displayLarge.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  trendPercentage:
                      '${provider.weeklyPercentageChange.toStringAsFixed(2)}% This Week',
                  chartData: provider.weeklyChartData,
                )
              else if (_selectedTimeFrame == 'Monthly')
                ExpenseTrendChartCard(
                  timeFrame: 'Monthly',
                  title: 'Expense (${DateFormat('MMMM').format(DateTime.now())})',
                  amount: PrivacyMaskedText(
                    amount: provider.currentMonthExpense,
                    isMasked: _localMasked,
                    style: AppTextStyles.displayLarge.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  trendPercentage:
                      '${provider.monthlyPercentageChange.toStringAsFixed(2)}% This Month',
                  chartData: provider.monthlyChartData,
                )
              else if (_selectedTimeFrame == 'Quarterly')
                ExpenseTrendChartCard(
                  timeFrame: 'Quarterly',
                  title: 'Expense (This Quarter)',
                  amount: PrivacyMaskedText(
                    amount: provider.currentQuarterExpense,
                    isMasked: _localMasked,
                    style: AppTextStyles.displayLarge.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  trendPercentage:
                      '${provider.quarterlyPercentageChange.toStringAsFixed(2)}% This Quarter',
                  chartData: provider.quarterlyChartData,
                ),

              if (_selectedTimeFrame == 'Monthly') ...[
                const SizedBox(height: 20),
                ExpenseCategoriesBreakdownCard(
                  suffixText: '(This Month)',
                  totalAmount: PrivacyMaskedText(
                    amount: provider.currentMonthExpense,
                    isMasked: _localMasked,
                    style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  categories: provider.monthlyCategories,
                  isMasked: _localMasked,
                ),
              ] else if (_selectedTimeFrame == 'Quarterly') ...[
                const SizedBox(height: 20),
                ExpenseCategoriesBreakdownCard(
                  suffixText: '(This Quarter)',
                  totalAmount: PrivacyMaskedText(
                    amount: provider.currentQuarterExpense,
                    isMasked: _localMasked,
                    style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  categories: provider.quarterlyCategories,
                  isMasked: _localMasked,
                ),
              ],

              if (_selectedTimeFrame == 'Quarterly') ...[
                const SizedBox(height: 20),
                ExpenseBreakdownCard(
                  suffixText: '(This Quarter)',
                  items: provider.quarterlyBreakdowns,
                  isMasked: _localMasked,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
