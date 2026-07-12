import 'package:flutter/material.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_balances.dart';

class TourDashboardExpenseChart extends StatelessWidget {
  final List<TourParticipant> participants;
  final Map<String, double> balances;
  final String currency;
  final double outstanding;
  final String Function(double) formatAmount;
  final VoidCallback onSettleUp;

  const TourDashboardExpenseChart({
    super.key,
    required this.participants,
    required this.balances,
    required this.currency,
    required this.outstanding,
    required this.formatAmount,
    required this.onSettleUp,
  });

  @override
  Widget build(BuildContext context) {
    return TourMemberBalances(
      participants: participants,
      balances: balances,
      currency: currency,
      outstanding: outstanding,
      formatAmount: formatAmount,
      onSettleUp: onSettleUp,
    );
  }
}
