import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_expense_share.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/features/tours/widgets/add_expense_sheet.dart';
import 'package:expense_tracker/features/tours/pages/settle_up_screen.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/widgets/tour_summary_row.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_balances.dart';
import 'package:expense_tracker/features/tours/widgets/tour_expense_tile.dart';
import 'package:expense_tracker/features/tours/widgets/tour_expense_details_sheet.dart';
import 'package:expense_tracker/features/tours/widgets/tour_export_options_sheet.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_required_dialog.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/features/tours/widgets/invite_code_card.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
      showDialog(
        context: context,
        builder: (ctx) => TourMemberRequiredDialog(tourId: widget.tourId),
      );
      return false;
    }
    return true;
  }

  void _showExportOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TourExportOptionsSheet(tourId: widget.tourId),
    );
  }

  void _openMemberManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TourMemberManagementScreen(
          tourId: widget.tourId,
          isInitialSetup: false,
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
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = tour.ownerUid != null && currentUid != null && tour.ownerUid == currentUid;

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
            onPressed: () => _openMemberManagement(context),
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.p8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.2)
                    : AppColors.selectionGreenBg,
                borderRadius: BorderRadius.circular(AppSpacing.r10),
              ),
              child: const Icon(
                Icons.person_add_alt_rounded,
                size: 20,
                color: AppColors.activeGreen,
              ),
            ),
            tooltip: 'Manage Members',
          ),

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
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TourProvider>().refreshTourData();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 100),
          children: [
            TourSummaryRow(
              totalSpentText: totalSpentText,
              outstandingText: outstandingText,
              isSettled: isSettled,
            ),
            if (tour.inviteCode != null && tour.inviteCode!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InviteCodeCard(
                inviteCode: tour.inviteCode!,
                tourName: tour.name,
              ),
            ],
            if (participants.isNotEmpty) ...[
              const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
                isOwner,
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 0),
        child: FloatingActionButton.extended(
          heroTag: 'tour_dashboard_fab',
          onPressed: () {
            if (tour.isCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tour is completed — cannot add expenses'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            if (_ensureMinimumMembers()) {
              AddExpenseSheet.show(
                context,
                tourId: widget.tourId,
                participants: participants,
                currency: tour.currency,
              );
            }
          },
          backgroundColor: tour.isCompleted
              ? AppColors.activeGreen.withValues(alpha: 0.35)
              : AppColors.activeGreen,
          icon: Icon(Icons.add_rounded,
              color: AppColors.white.withValues(alpha: tour.isCompleted ? 0.5 : 1),
              size: 20),
          label: Text(
            'Add Expense',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: tour.isCompleted ? 0.5 : 1),
            ),
          ),
          elevation: tour.isCompleted ? 0 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.r8),
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
            style: AppTextStyles.h2.copyWith(
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
              style: AppTextStyles.caption.copyWith(
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
    bool isOwner,
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
              isOwner,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _editExpense(TourExpense expense) {
    final provider = context.read<TourProvider>();
    AddExpenseSheet.show(
      context,
      tourId: widget.tourId,
      participants: provider.participants,
      currency: provider.selectedTour?.currency ?? 'USD',
      expenseToEdit: expense,
    );
  }

  void _showExpenseDetailsSheet(
    BuildContext context,
    TourExpense expense,
    String payerName,
    String currency,
    bool isOwner,
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
          showDelete: isOwner,
          onDelete: () {
            Navigator.pop(ctx);
            _confirmDeleteExpense(context, expense.id);
          },
          onEdit: () {
            Navigator.pop(ctx);
            _editExpense(expense);
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
          style: AppTextStyles.dialogTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
          style: AppTextStyles.body.copyWith(
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
              final success = await context.read<TourProvider>().deleteExpense(expenseId);
              if (mounted) {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Expense deleted successfully'),
                      backgroundColor: AppColors.activeGreen,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Only the tour creator can delete expenses'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
      padding: EdgeInsets.only(
        top: 4,
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.noExpense, height: 140, width: 140),

            Text(
              'No expenses yet',
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add the first expense',
              style: AppTextStyles.bodySmall.copyWith(
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
