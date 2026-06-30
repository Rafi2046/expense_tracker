import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_expense_share.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/features/tours/widgets/add_expense_sheet.dart';
import 'package:expense_tracker/features/tours/widgets/member_avatar_stack.dart';
import 'package:expense_tracker/features/tours/pages/settle_up_screen.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';

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
      'BDT': '৳',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
      'AED': 'د.إ',
      'CAD': '\$',
    };
    return symbols[code] ?? '\$';
  }

  String _formatAmount(double amount, String currency) {
    final symbol = _currencySymbol(currency);
    final formatted = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    return '$symbol$formatted';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.br20)),
        backgroundColor: AppColors.white,
        title: Text('Members Required', style: AppTextStyles.dialogTitle),
        content: Text('You need at least 2 members in the tour to add expenses or settle up.', style: AppTextStyles.dialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.loginSubTitle)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.br8)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TourMemberManagementScreen(tourId: widget.tourId)),
              );
            },
            child: const Text('Add Members', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TourProvider>();
    final tour = provider.selectedTour;

    if (tour == null && provider.isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (tour == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Tour not found')),
      );
    }

    final participants = provider.participants;
    final expenses = provider.expenses;
    final shares = provider.shares;
    final netBalances = provider.netBalances(tour.id);
    final totalFund = provider.totalFundCollected(tour.id);
    final cashInHand = provider.cashInHand(tour.id, participants.isNotEmpty
        ? participants.first.id
        : '');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeroHeader(theme, tour.name, tour.currency),
          SliverToBoxAdapter(child: _buildFundSummary(theme, totalFund, cashInHand, tour.currency)),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TourMemberManagementScreen(tourId: widget.tourId))),
              child: _buildMemberSection(theme, participants, netBalances),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          expenses.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyExpenses(theme),
                )
              : _buildExpenseList(theme, expenses, shares, participants, tour.currency),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.h48),
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
          backgroundColor: AppColors.activeGreen,
          icon: const Icon(Icons.add_rounded, color: AppColors.white),
          label: const Text('Add Expense', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontFamily: 'WorkSans')),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.br30)),
        ),
      ),
    );
  }

  // ─── Hero Header ──────────────────────────────────────────────────

  Widget _buildHeroHeader(ThemeData theme, String name, String currency) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 16,
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currencySymbol(currency),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ─── Fund Summary ─────────────────────────────────────────────────

  Widget _buildFundSummary(
      ThemeData theme, double totalFund, double cashInHand, String currency) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Fund',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatAmount(totalFund, currency),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2EBD85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Cash in Hand',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatAmount(cashInHand, currency),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: cashInHand >= 0
                                    ? const Color(0xFF2EBD85)
                                    : const Color(0xFFDC3545),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (_ensureMinimumMembers()) {
                          _openSettleUp();
                        }
                      },
                      icon: const Icon(Icons.balance_rounded, size: 18),
                      label: const Text('Settle Up'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSettleUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettleUpScreen(tourId: widget.tourId),
      ),
    );
  }

  // ─── Member Section ───────────────────────────────────────────────

  Widget _buildMemberSection(
      ThemeData theme, List participants, Map<String, double> balances) {
    if (participants.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${participants.length} ${participants.length == 1 ? 'person' : 'people'}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MemberAvatarStack(
            participants: participants.cast(),
            balances: balances,
          ),
        ],
      ),
    );
  }

  // ─── Expense Feed ─────────────────────────────────────────────────

  Widget _buildExpenseList(
      ThemeData theme,
      List<TourExpense> expenses,
      List<TourExpenseShare> shares,
      List participants,
      String currency) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final expense = expenses[index];
          final payer = participants.cast().firstWhere(
            (p) => p.id == expense.paidBy,
            orElse: () => null,
          );
          final expenseShares =
              shares.where((s) => s.expenseId == expense.id).toList();
          final includedCount =
              expenseShares.where((s) => !s.isExcluded).length;

          return _ExpenseTile(
            theme: theme,
            expense: expense,
            payerName: payer?.name ?? 'Unknown',
            payerInitials: payer != null
                ? (payer.name.isNotEmpty ? payer.name[0].toUpperCase() : '?')
                : '?',
            includedCount: includedCount,
            formatAmount: (v) => _formatAmount(v, currency),
          );
        },
        childCount: expenses.length,
      ),
    );
  }

  Widget _buildEmptyExpenses(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add the first expense',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Tile ─────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final ThemeData theme;
  final TourExpense expense;
  final String payerName;
  final String payerInitials;
  final int includedCount;
  final String Function(double) formatAmount;

  const _ExpenseTile({
    required this.theme,
    required this.expense,
    required this.payerName,
    required this.payerInitials,
    required this.includedCount,
    required this.formatAmount,
  });

  String _splitLabel() {
    switch (expense.splitType) {
      case 'equal':
        return 'Split equally among $includedCount';
      case 'exact':
        return 'Split by exact amounts';
      case 'percentage':
        return 'Split by percentages';
      case 'exclusion':
        return 'Split among $includedCount (exclusions)';
      default:
        return 'Split equally among $includedCount';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF667eea),
              child: Text(
                payerInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _splitLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatAmount(expense.amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
