import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_expense_share.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/features/tours/widgets/add_expense_sheet.dart';
import 'package:expense_tracker/features/tours/pages/settle_up_screen.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/features/tours/utils/tour_export_service.dart';

const Color _bgColor = Color(0xFFF7F9FA);

class TourDashboardScreen extends StatefulWidget {
  final String tourId;

  const TourDashboardScreen({super.key, required this.tourId});

  @override
  State<TourDashboardScreen> createState() => _TourDashboardScreenState();
}

class _TourDashboardScreenState extends State<TourDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TourProvider>().selectTour(widget.tourId);
    });
  }

  String _currencySymbol(String code) {
    const symbols = {
      'BDT': '৳', 'USD': r'$', 'EUR': '€', 'GBP': '£',
      'INR': '₹', 'JPY': '¥', 'AED': 'د.إ', 'CAD': r'$',
    };
    return symbols[code] ?? r'$';
  }

  String _formatAmount(double amount, String currency) {
    final symbol = _currencySymbol(currency);
    if (amount == amount.roundToDouble()) {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  bool _ensureMinimumMembers() {
    final participants = context.read<TourProvider>().participants;
    if (participants.length < 2) {
      _showMemberRequiredDialog();
      return false;
    }
    return true;
  }

  void _showMemberRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: const Text('Members Required', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
        content: const Text(
          'You need at least 2 members in the tour to add expenses or settle up.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TourMemberManagementScreen(tourId: widget.tourId),
                ),
              );
            },
            child: const Text('Add Members', style: TextStyle(color: Color(0xFF2EBD85), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final tour = provider.selectedTour;

    if (tour == null && provider.isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tour == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton()),
        body: const Center(child: Text('Tour not found', style: TextStyle(color: Color(0xFF6B7280)))),
      );
    }

    final participants = provider.participants;
    final expenses = provider.expenses;
    final shares = provider.shares;
    final netBalances = provider.netBalances(tour.id);
    final totalSpent = provider.totalSpent(tour.id);
    final totalOutstanding = provider.totalOutstanding(tour.id);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1F2937)),
        title: Text(
          tour.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF1F2937)),
        ),
        actions: [
          IconButton(
            onPressed: () => TourExportService.shareReport(context, widget.tourId),
            icon: const Icon(Icons.ios_share_rounded, size: 20, color: Color(0xFF6B7280)),
            tooltip: 'Share Report',
          ),
          TextButton.icon(
            onPressed: () {
              if (_ensureMinimumMembers()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TourMemberManagementScreen(tourId: widget.tourId),
                  ),
                );
              }
            },
            icon: const Icon(Icons.people_outline_rounded, size: 18, color: Color(0xFF6B7280)),
            label: const Text('Members', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _buildSummaryRow(totalSpent, totalOutstanding, tour.currency),
          if (participants.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildMemberBalances(participants, netBalances, tour.currency, totalOutstanding),
          ],
          const SizedBox(height: 24),
          _buildExpensesHeader(expenses.length),
          if (expenses.isEmpty)
            _buildEmptyState()
          else
            _buildExpenseList(expenses, shares, participants, tour.currency),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: FloatingActionButton.extended(
          heroTag: 'tour_dashboard_fab',
          onPressed: () {
            if (_ensureMinimumMembers()) {
              AddExpenseSheet.show(
                context,
                tourId: widget.tourId,
                participants: participants,
                currency: tour.currency,
              );
            }
          },
          backgroundColor: const Color(0xFF2EBD85),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ─── Summary Row ─────────────────────────────────────────────────────

  Widget _buildSummaryRow(double totalSpent, double totalOutstanding, String currency) {
    final isSettled = totalOutstanding == 0;
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total spent', _formatAmount(totalSpent, currency), const Color(0xFF1F2937))),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            isSettled ? 'All settled' : 'Outstanding',
            isSettled ? '✓' : _formatAmount(totalOutstanding, currency),
            isSettled ? const Color(0xFF2EBD85) : const Color(0xFFDC3545),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }

  // ─── Member Balances ─────────────────────────────────────────────────

  Widget _buildMemberBalances(List participants, Map<String, double> balances, String currency, double outstanding) {
    final allParticipants = participants.cast<TourParticipant>();
    final hasDebts = outstanding > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 12),
          child: Text('Balances', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
        ),
        ...allParticipants.asMap().entries.map(
          (entry) => _buildMemberBalanceRow(entry.value, entry.key, allParticipants, balances, currency),
        ),
        if (hasDebts) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                if (_ensureMinimumMembers()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettleUpScreen(tourId: widget.tourId),
                    ),
                  );
                }
              },
              child: const Text(
                'Settle Up',
                style: TextStyle(color: Color(0xFF2EBD85), fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMemberBalanceRow(
    TourParticipant p,
    int index,
    List<TourParticipant> allParticipants,
    Map<String, double> balances,
    String currency,
  ) {
    final balance = balances[p.id] ?? 0;
    final isOwed = balance > 0;
    final isSettled = balance == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _avatarColor(index),
              child: Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
            ),
            if (isSettled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Settled', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF))),
              )
            else if (isOwed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Gets back ${_formatAmount(balance, currency)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2EBD85)),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Owes ${_formatAmount(balance.abs(), currency)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC3545)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Expenses ────────────────────────────────────────────────────────

  Widget _buildExpensesHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 12),
      child: Row(
        children: [
          const Text('Expenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          const SizedBox(width: 8),
          Text(
            '$count ${count == 1 ? 'entry' : 'entries'}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(
    List<TourExpense> expenses,
    List<TourExpenseShare> shares,
    List participants,
    String currency,
  ) {
    final allParticipants = participants.cast<TourParticipant>();
    return Column(
      children: expenses.map((expense) {
        final payer = allParticipants.firstWhere(
          (p) => p.id == expense.paidBy,
          orElse: () => TourParticipant(
            id: expense.paidBy,
            tourId: expense.tourId,
            name: 'Unknown',
            joinedAt: expense.date,
          ),
        );
        final expenseShares = shares.where((s) => s.expenseId == expense.id).toList();
        final includedCount = expenseShares.where((s) => !s.isExcluded).length;
        final payerIdx = allParticipants.indexWhere((p) => p.id == expense.paidBy);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ExpenseTile(
            expense: expense,
            payerName: payer.name,
            avatarColor: _avatarColor(payerIdx),
            includedCount: includedCount,
            formatAmount: (v) => _formatAmount(v, currency),
          ),
        );
      }).toList(),
    );
  }

  Color _avatarColor(int index) {
    if (index < 0) return const Color(0xFF6366F1);
    const colors = [
      Color(0xFF6366F1), Color(0xFFEC4899), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFF06B6D4), Color(0xFF8B5CF6),
      Color(0xFFEF4444), Color(0xFF14B8A6),
    ];
    return colors[index % colors.length];
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            const Text('No expenses yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
            const SizedBox(height: 4),
            const Text('Tap + to add the first expense', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Tile ───────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final TourExpense expense;
  final String payerName;
  final Color avatarColor;
  final int includedCount;
  final String Function(double) formatAmount;

  const _ExpenseTile({
    required this.expense,
    required this.payerName,
    required this.avatarColor,
    required this.includedCount,
    required this.formatAmount,
  });

  String _splitLabel() {
    switch (expense.splitType) {
      case 'equal': return 'Split equally among $includedCount';
      case 'exact': return 'Split by exact amounts';
      case 'percentage': return 'Split by percentages';
      case 'exclusion': return 'Split among $includedCount (exclusions)';
      default: return 'Split equally among $includedCount';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor,
            child: Text(
              payerName.isNotEmpty ? payerName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${payerName.split(' ').first} · ${_splitLabel()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatAmount(expense.amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }
}
