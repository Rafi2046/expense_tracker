import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_expense_share.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/features/tours/widgets/tour_expense_tile.dart';

class TourDashboardMemberList extends StatelessWidget {
  final List<TourExpense> expenses;
  final List<TourExpenseShare> shares;
  final List<TourParticipant> participants;
  final String currency;
  final bool isOwner;
  final String Function(double) formatAmount;
  final void Function(
    TourExpense expense,
    String payerName,
    String currency,
    bool isOwner,
  ) onExpenseTap;

  const TourDashboardMemberList({
    super.key,
    required this.expenses,
    required this.shares,
    required this.participants,
    required this.currency,
    required this.isOwner,
    required this.formatAmount,
    required this.onExpenseTap,
  });

  Color _avatarColor(int index) {
    if (index < 0) return const Color(0xFF6366F1);
    const colors = [
      Color(0xFF6366F1),
      Color(0xFFEC4899),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF14B8A6),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: expenses.map((expense) {
        final payer = participants.firstWhere(
          (p) => p.id == expense.paidBy,
          orElse: () => TourParticipant(
            id: expense.paidBy,
            tourId: expense.tourId,
            name: 'Unknown',
            joinedAt: expense.date,
          ),
        );
        final expenseShares = shares
            .where((s) => s.expenseId == expense.id)
            .toList();
        final includedCount = expenseShares.where((s) => !s.isExcluded).length;
        final payerIdx = participants.indexWhere(
          (p) => p.id == expense.paidBy,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: TourExpenseTile(
            theme: theme,
            expense: expense,
            payerName: payer.name,
            avatarColor: _avatarColor(payerIdx),
            includedCount: includedCount,
            formatAmount: (v) => formatAmount(v),
            onTap: () => onExpenseTap(expense, payer.name, currency, isOwner),
          ),
        );
      }).toList(),
    );
  }
}
