import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/widgets/add_expense_sheet.dart';
import 'package:expense_tracker/features/tours/pages/settle_up_screen.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/widgets/tour_expense_details_sheet.dart';
import 'package:expense_tracker/features/tours/widgets/tour_export_options_sheet.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_required_dialog.dart';
import 'package:expense_tracker/features/tours/pages/tour_member_management_screen.dart';
import 'package:expense_tracker/features/tours/widgets/invite_code_card.dart';
import 'package:expense_tracker/features/tours/widgets/tour_dashboard_summary_card.dart';
import 'package:expense_tracker/features/tours/widgets/tour_dashboard_stats_row.dart';
import 'package:expense_tracker/features/tours/widgets/tour_dashboard_expense_chart.dart';
import 'package:expense_tracker/features/tours/widgets/tour_dashboard_member_list.dart';
import 'package:expense_tracker/features/tours/widgets/tour_dashboard_recent_activity.dart';
import 'package:expense_tracker/features/tours/widgets/tour_dashboard_quick_actions.dart';
import 'package:expense_tracker/features/tours/widgets/create_tour_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  void _openEditTourSheet(Tour tour) {
    CreateTourSheet.show(
      context: context,
      tour: tour,
      onTourCreated: (_) {},
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
        body: Center(
          child: Text(
            context.translate('tour_not_found'),
            style: const TextStyle(color: Color(0xFF6B7280)),
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
                LucideIcons.userPlus,
                size: 20,
                color: AppColors.activeGreen,
              ),
            ),
            tooltip: context.translate('manage_members_tooltip'),
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
                LucideIcons.share,
                size: 20,
                color: AppColors.activeGreen,
              ),
            ),
            tooltip: context.translate('export_tooltip'),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit_tour') {
                _openEditTourSheet(tour);
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: Container(
              padding: const EdgeInsets.all(AppSpacing.p8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.2)
                    : AppColors.selectionGreenBg,
                borderRadius: BorderRadius.circular(AppSpacing.r10),
              ),
              child: const Icon(
                LucideIcons.moreVertical,
                size: 20,
                color: AppColors.activeGreen,
              ),
            ),
            itemBuilder: (context) => [
              if (isOwner)
                PopupMenuItem(
                  value: 'edit_tour',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 18, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 10),
                      Text(context.translate('edit_tour'), style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface)),
                    ],
                  ),
                ),
            ],
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
            if (isOwner) ...[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('shared_tours')
                    .doc(tour.id)
                    .collection('join_requests')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final docs = snapshot.data!.docs;

                  return Column(
                    children: [
                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final requesterUid = doc.id;
                        final name = data['name'] as String? ?? 'Friend';
                        final email = data['email'] as String? ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(AppSpacing.p16),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? theme.cardColor 
                                : AppColors.selectionGreenBg.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppSpacing.br12),
                            border: Border.all(
                              color: AppColors.activeGreen.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.p8),
                                    decoration: BoxDecoration(
                                      color: AppColors.activeGreen.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.userCheck,
                                      size: 20,
                                      color: AppColors.activeGreen,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          context.translate('join_request_label'),
                                          style: AppTextStyles.label.copyWith(
                                            color: AppColors.activeGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          name,
                                          style: AppTextStyles.h3.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        if (email.isNotEmpty)
                                          Text(
                                            email,
                                            style: AppTextStyles.caption.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.h12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await context.read<TourProvider>().rejectJoinRequest(
                                          tour.id,
                                          requesterUid,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.activeRed,
                                        side: const BorderSide(color: AppColors.activeRed),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: Text(context.translate('decline_button')),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await context.read<TourProvider>().approveJoinRequest(
                                          tour,
                                          requesterUid,
                                          name,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.activeGreen,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: Text(context.translate('accept_button')),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
            TourDashboardSummaryCard(
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
              TourDashboardExpenseChart(
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
            TourDashboardStatsRow(expenseCount: expenses.length),
            if (expenses.isEmpty)
              const TourDashboardRecentActivity()
            else
              TourDashboardMemberList(
                expenses: expenses,
                shares: shares,
                participants: participants.cast<TourParticipant>(),
                currency: tour.currency,
                isOwner: isOwner,
                formatAmount: (v) => _formatAmount(v, tour.currency),
                onExpenseTap: (expense, payerName, currency, isOwner) =>
                    _showExpenseDetailsSheet(
                      context, expense, payerName, currency, isOwner),
              ),
          ],
        ),
      ),
      floatingActionButton: TourDashboardQuickActions(
        isCompleted: tour.isCompleted,
        onAddExpense: () {
          if (tour.isCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('tour_completed_no_expense')),
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
      ),
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
          context.translate('delete_expense_title'),
          style: AppTextStyles.dialogTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          context.translate('delete_expense_confirm_msg'),
          style: AppTextStyles.body.copyWith(
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.translate('cancel_button'),
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
              if (context.mounted) {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(context.translate('expense_deleted')),
                      backgroundColor: AppColors.activeGreen,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(context.translate('only_creator_delete_expense')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              context.translate('delete_button'),
              style: const TextStyle(
                color: AppColors.activeRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
