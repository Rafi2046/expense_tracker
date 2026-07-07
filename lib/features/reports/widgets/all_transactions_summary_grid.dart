import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/report_stat_card.dart';

class AllTransactionsSummaryGrid extends StatelessWidget {
  final bool isMasked;

  const AllTransactionsSummaryGrid({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final totals = reportsProvider.allTransactionsTotals;

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
          isPositive: true,
          isMasked: isMasked,
        ),
        ReportStatCard(
          title: 'Total Payments Out',
          amount: totals['totalPaymentsOut'] ?? 0.0,
          isPositive: false,
          isMasked: isMasked,
        ),
        ReportStatCard(
          title: 'Total Income',
          amount: totals['totalIncome'] ?? 0.0,
          isPositive: true,
          isMasked: isMasked,
        ),
        ReportStatCard(
          title: 'Total Expense',
          amount: totals['totalExpense'] ?? 0.0,
          isPositive: false,
          isMasked: isMasked,
        ),
      ],
    );
  }
}
