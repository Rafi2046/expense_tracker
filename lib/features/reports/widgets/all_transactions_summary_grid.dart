import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/reports/widgets/report_stat_card.dart';

class AllTransactionsSummaryGrid extends StatelessWidget {
  const AllTransactionsSummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final totals = reportsProvider.allTransactionsTotals;
    final currencySymbol = context.currencySymbol;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        ReportStatCard(
          title: 'Total Payments In',
          amount: totals['totalPaymentsIn'] ?? 0.0,
          currencySymbol: currencySymbol,
          isPositive: true,
        ),
        ReportStatCard(
          title: 'Total Payments Out',
          amount: totals['totalPaymentsOut'] ?? 0.0,
          currencySymbol: currencySymbol,
          isPositive: false,
        ),
        ReportStatCard(
          title: 'Total Income',
          amount: totals['totalIncome'] ?? 0.0,
          currencySymbol: currencySymbol,
          isPositive: true,
        ),
        ReportStatCard(
          title: 'Total Expense',
          amount: totals['totalExpense'] ?? 0.0,
          currencySymbol: currencySymbol,
          isPositive: false,
        ),
      ],
    );
  }
}
