import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_expense_share.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
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

  String _payerNames(Map<String, double> paidBy, BuildContext context) {
    final names = <String>[];
    for (final id in paidBy.keys) {
      final p = participants.firstWhere(
        (p) => p.id == id,
        orElse: () => TourParticipant(
          id: id,
          tourId: '',
          name: context.translate('unknown_member'),
          joinedAt: DateTime.now(),
        ),
      );
      names.add(p.name.split(' ').first);
    }
    if (names.isEmpty) return context.translate('unknown_member');
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names.first} ${context.translate('and_separator')} ${names.last}';
    return '${names.first}, ${names[1]} ${context.translate('and_separator')} ${names.last}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: expenses.map((expense) {
        final firstPayerId = expense.paidBy.keys.isNotEmpty
            ? expense.paidBy.keys.first
            : '';
        final firstPayerIdx = participants.indexWhere(
          (p) => p.id == firstPayerId,
        );
        final expenseShares = shares
            .where((s) => s.expenseId == expense.id)
            .toList();
        final includedCount = expenseShares.where((s) => !s.isExcluded).length;
        final payerNameStr = _payerNames(expense.paidBy, context);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: TourExpenseTile(
            theme: theme,
            expense: expense,
            payerName: payerNameStr,
            avatarColor: _avatarColor(firstPayerIdx),
            includedCount: includedCount,
            formatAmount: (v) => formatAmount(v),
            onTap: () => onExpenseTap(expense, payerNameStr, currency, isOwner),
          ),
        );
      }).toList(),
    );
  }
}
