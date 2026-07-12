import 'package:flutter/material.dart';
import 'package:expense_tracker/features/tours/widgets/tour_summary_row.dart';

class TourDashboardSummaryCard extends StatelessWidget {
  final String totalSpentText;
  final String outstandingText;
  final bool isSettled;

  const TourDashboardSummaryCard({
    super.key,
    required this.totalSpentText,
    required this.outstandingText,
    required this.isSettled,
  });

  @override
  Widget build(BuildContext context) {
    return TourSummaryRow(
      totalSpentText: totalSpentText,
      outstandingText: outstandingText,
      isSettled: isSettled,
    );
  }
}
