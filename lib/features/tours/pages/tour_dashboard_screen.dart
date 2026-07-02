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
import 'package:expense_tracker/features/tours/utils/tour_invoice_generator.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/features/tours/widgets/tour_summary_row.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_balances.dart';
import 'package:expense_tracker/features/tours/widgets/tour_expense_tile.dart';
import 'package:expense_tracker/features/tours/widgets/tour_expense_details_sheet.dart';

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
      'USD': r'$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
      'AED': 'د.إ',
      'CAD': r'$',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r16),
        ),
        backgroundColor: AppColors.white,
        title: const Text(
          'Members Required',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        content: const Text(
          'You need at least 2 members in the tour to add expenses or settle up.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TourMemberManagementScreen(tourId: widget.tourId),
                ),
              );
            },
            child: const Text(
              'Add Members',
              style: TextStyle(
                color: AppColors.activeGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptionsSheet(BuildContext context) {
    final provider = context.read<TourProvider>();
    final tour = provider.selectedTour;
    if (tour == null) return;

    final participants = provider.participants;
    final expenses = provider.expenses;
    final netBalances = provider.netBalances(tour.id);
    final totalSpent = provider.totalSpent(tour.id);
    final totalOutstanding = provider.totalOutstanding(tour.id);
    final settlements = simplifyDebts(netBalances);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom +
              20,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Export Report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how to share your tour details',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _ExportOptionTile(
                icon: Icons.image_rounded,
                title: 'Share Balances Image',
                subtitle: 'A snapshot showing who owes whom',
                gradientColors: const [Color(0xFF059669), Color(0xFF0F766E)],
                onTap: () {
                  Navigator.pop(ctx);
                  TourExportService.shareReport(context, widget.tourId);
                },
              ),
              const SizedBox(height: 12),
              _ExportOptionTile(
                icon: Icons.description_rounded,
                title: 'Download Detailed Invoice (PDF)',
                subtitle: 'Full report with category breakdown & ledger table',
                gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                onTap: () {
                  Navigator.pop(ctx);
                  TourInvoiceGenerator.generateAndShare(
                    tour: tour,
                    participants: participants,
                    expenses: expenses,
                    settlements: settlements,
                    totalSpent: totalSpent,
                    totalOutstanding: totalOutstanding,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final tour = provider.selectedTour;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          backgroundColor:
              theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
          elevation: 0,
          leading: BackButton(
            color:
                theme.appBarTheme.iconTheme?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        body: const Center(
          child: Text(
            'Tour not found',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    final participants = provider.participants;
    final expenses = provider.expenses;
    final shares = provider.shares;
    final netBalances = provider.netBalances(tour.id);
    final totalSpent = provider.totalSpent(tour.id);
    final totalOutstanding = provider.totalOutstanding(tour.id);

    final totalSpentText = _formatAmount(totalSpent, tour.currency);
    final outstandingText = _formatAmount(totalOutstanding, tour.currency);
    final isSettled = totalOutstanding == 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(
          color:
              theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onSurface,
        ),
        title: Text(
          tour.name,
          style: AppTextStyles.reportAppBarTitle.copyWith(
            color:
                theme.appBarTheme.titleTextStyle?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showExportOptionsSheet(context),
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.p8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.2)
                    : AppColors.selectionGreenBg,
                borderRadius: BorderRadius.circular(AppSpacing.r10),
              ),
              child: const Icon(
                Icons.ios_share_rounded,
                size: 20,
                color: AppColors.activeGreen,
              ),
            ),
            tooltip: 'Export',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 100),
        children: [
          TourSummaryRow(
            totalSpentText: totalSpentText,
            outstandingText: outstandingText,
            isSettled: isSettled,
          ),
          if (participants.isNotEmpty) ...[
            const SizedBox(height: 24),
            TourMemberBalances(
              participants: participants,
              balances: netBalances,
              currency: tour.currency,
              outstanding: totalOutstanding,
              formatAmount: (val) => _formatAmount(val, tour.currency),
              onSettleUp: () {
                if (_ensureMinimumMembers()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettleUpScreen(tourId: widget.tourId),
                    ),
                  );
                }
              },
            ),
          ],
          const SizedBox(height: 24),
          _buildExpensesHeader(theme, expenses.length),
          if (expenses.isEmpty)
            _buildEmptyState(theme)
          else
            _buildExpenseList(
              theme,
              expenses,
              shares,
              participants,
              tour.currency,
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
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
          icon: const Icon(Icons.add_rounded, color: AppColors.white, size: 20),
          label: const Text(
            'Add Expense',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.r16),
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesHeader(ThemeData theme, int count) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Text(
            'Expenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(
    ThemeData theme,
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
        final expenseShares = shares
            .where((s) => s.expenseId == expense.id)
            .toList();
        final includedCount = expenseShares.where((s) => !s.isExcluded).length;
        final payerIdx = allParticipants.indexWhere(
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
            formatAmount: (v) => _formatAmount(v, currency),
            onTap: () => _showExpenseDetailsSheet(
              context,
              expense,
              payer.name,
              currency,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showExpenseDetailsSheet(
    BuildContext context,
    TourExpense expense,
    String payerName,
    String currency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TourExpenseDetailsSheet(
          expense: expense,
          payerName: payerName,
          currency: currency,
          formatAmount: _formatAmount,
          onDelete: () {
            Navigator.pop(ctx);
            _confirmDeleteExpense(context, expense.id);
          },
        );
      },
    );
  }

  void _confirmDeleteExpense(BuildContext context, String expenseId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.cardColor,
        title: Text(
          'Delete Expense',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await context.read<TourProvider>().deleteExpense(expenseId);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Expense deleted successfully'),
                    backgroundColor: AppColors.activeGreen,
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting expense: $e'),
                    backgroundColor: AppColors.activeRed,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.activeRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: isDark ? const Color(0xFF2D2D3D) : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add the first expense',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
