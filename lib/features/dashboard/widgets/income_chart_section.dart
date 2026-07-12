import 'package:expense_tracker/features/dashboard/widgets/income_daily_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_weekly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_monthly_section.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_quarterly_section.dart';
import 'package:flutter/material.dart';

class IncomeChartSection extends StatelessWidget {
  final String selectedTimeFrame;
  final bool isMasked;

  const IncomeChartSection({
    super.key,
    required this.selectedTimeFrame,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedTimeFrame) {
      case 'Daily':
        return IncomeDailySection(isMasked: isMasked);
      case 'Weekly':
        return IncomeWeeklySection(isMasked: isMasked);
      case 'Quarterly':
        return IncomeQuarterlySection(isMasked: isMasked);
      case 'Monthly':
      default:
        return IncomeMonthlySection(isMasked: isMasked);
    }
  }
}
