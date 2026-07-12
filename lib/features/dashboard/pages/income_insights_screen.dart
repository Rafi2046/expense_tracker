import 'package:expense_tracker/core/providers/income_analytics_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/financial_health_banner.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_chart_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_insights_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_period_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_summary_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IncomeInsightsScreen extends StatefulWidget {
  const IncomeInsightsScreen({super.key});

  @override
  State<IncomeInsightsScreen> createState() => _IncomeInsightsScreenState();
}

class _IncomeInsightsScreenState extends State<IncomeInsightsScreen> {
  String _selectedTimeFrame = 'Monthly';
  static bool _localMasked = false;

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<IncomeAnalyticsProvider>();
    return Scaffold(
      appBar: IncomeInsightsHeader(
        onBack: () => Navigator.pop(context),
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
              IncomeSummaryRow(
                analytics: analytics,
                selectedTimeFrame: _selectedTimeFrame,
                isMasked: _localMasked,
                onToggleMask: () => setState(() => _localMasked = !_localMasked),
              ),
              const SizedBox(height: 16),
              IncomePeriodSelector(
                selectedTimeFrame: _selectedTimeFrame,
                onTimeFrameChanged: (tf) {
                  setState(() => _selectedTimeFrame = tf);
                },
              ),
              const SizedBox(height: 16),
              IncomeChartSection(
                selectedTimeFrame: _selectedTimeFrame,
                isMasked: _localMasked,
              ),
              const SizedBox(height: 16),
              FinancialHealthBanner(
                percentageChange: _selectedTimeFrame == 'Daily'
                    ? analytics.dailyPercentageChange
                    : _selectedTimeFrame == 'Weekly'
                    ? analytics.weeklyPercentageChange
                    : _selectedTimeFrame == 'Quarterly'
                    ? analytics.quarterlyPercentageChange
                    : analytics.monthlyPercentageChange,
                period: _selectedTimeFrame.toLowerCase(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
