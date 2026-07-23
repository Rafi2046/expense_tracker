import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/privacy_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/features/dashboard/pages/expense_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/recent_activity_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/income_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/notifications_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/to_give_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/to_receive_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_budget_status.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_stats_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_balance_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_quick_actions_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_transaction_list.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_summary_footer.dart';
import 'package:expense_tracker/features/reports/pages/view_reports_screen.dart';
import 'package:expense_tracker/features/reports/widgets/privacy_toggle_section.dart';
import 'package:expense_tracker/features/dashboard/pages/total_balance_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/budget_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;
    final debtProvider = context.watch<DebtProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final balanceProvider = context.watch<BalanceAnalyticsProvider>();
    final expenseAnalytics = context.watch<ExpenseAnalyticsProvider>();
    final double totalBalance = balanceProvider.allTimeTotalBalance;
    final String currentMonthName = context.formatMonth(DateTime.now());
    // Budget card needs both expense totals and budget limit before coloring.
    final isLoading = txProvider.isLoading || budgetProvider.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomepageAppbarWidget(
        onProfileTap: () {
          ProfileSwitchSheet.show(
            context: context,
            currentProfileId: currentProfile.id,
            profiles: profileProvider.profiles,
            onProfileSelected: (selectedProfile) async {
              // Persist + data-layer first, then UI — avoids ProxyProvider
              // snapping selection back to a stale profile mid-switch.
              await context.read<ProfileManagerProvider>().switchProfile(
                selectedProfile.id,
              );
              await profileProvider.selectProfile(selectedProfile);
            },
            onCreateNewTap: () async {
              final newProfile = await Navigator.push<UserProfile>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectProfileScreen(),
                ),
              );
              if (newProfile != null && context.mounted) {
                await context.read<ProfileManagerProvider>().switchProfile(
                  newProfile.id,
                );
              }
            },
          );
        },
        notificationOnTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data for the active profile only — never reload the
          // profile list (that was resetting selection from SharedPrefs).
          final tx = context.read<TransactionProvider>();
          final debt = context.read<DebtProvider>();
          final budget = context.read<BudgetProvider>();
          await Future.wait([
            tx.forceReload(),
            debt.forceReload(),
            budget.forceReload(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom + 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Privacy Mode Card
                PrivacyToggleSection(
                  isMasked: context.watch<PrivacyProvider>().isMasked,
                  onToggle: () {
                    HapticFeedback.lightImpact();
                    context.read<PrivacyProvider>().toggle();
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                DashboardStatsRow(
                  isLoading: isLoading,
                  incomeTitle:
                      '${context.translate('income')} ($currentMonthName)',
                  expenseTitle:
                      '${context.translate('expense')} ($currentMonthName)',
                  calendarMonthIncome: txProvider.calendarMonthIncome,
                  calendarMonthExpense: txProvider.calendarMonthExpense,
                  isCalendarIncomeTrendGood:
                      txProvider.isCalendarIncomeTrendGood,
                  isCalendarExpenseTrendGood:
                      txProvider.isCalendarExpenseTrendGood,
                  toReceiveTitle: context.translate('to_receive'),
                  toGiveTitle: context.translate('to_give'),
                  totalToReceive: debtProvider.totalToReceive,
                  totalToGive: debtProvider.totalToGive,
                  toReceivePendingCount: debtProvider.toReceiveUnpaid.length,
                  toGivePendingCount: debtProvider.toGiveUnpaid.length,
                  pendingLabel: context.translate('pending'),
                  onIncomeTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IncomeInsightsScreen(),
                      ),
                    );
                  },
                  onExpenseTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpenseInsightsScreen(),
                      ),
                    );
                  },
                  onToReceiveTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ToReceiveScreen(),
                      ),
                    );
                  },
                  onToGiveTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ToGiveScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s8),
                DashboardBalanceCard(
                  isLoading: isLoading,
                  cashBankTitle:
                      '${context.translate('cash')} & ${context.translate('bank')}',
                  totalBalanceLabel: context.translate('total_balance'),
                  totalBalance: totalBalance,
                  reportsTitle: context.translate('transactions_parties_in'),
                  reportsLabel: context.translate('reports'),
                  onCashBankTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TotalBalanceScreen(),
                      ),
                    );
                  },
                  onReportsTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewReportsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s8),
                DashboardQuickActionsRow(
                  isLoading: isLoading,
                  monthlyExpense: txProvider.calendarMonthExpense,
                ),
                DashboardTransactionList(
                  isLoading: isLoading,
                  transactions: txProvider.transactions,
                  onViewAllTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecentActivityScreen(),
                      ),
                    );
                  },
                  onTransactionTap: (tx) {
                    AddTransactionSheet.show(
                      context: context,
                      isIncome: tx.isIncome,
                      transaction: tx,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s8),
                DashboardSummaryFooter(
                  topCategoryName: expenseAnalytics.monthlyCategories.isNotEmpty
                      ? expenseAnalytics.monthlyCategories.first.name
                      : 'No Expenses',
                  topCategoryPercentage:
                      expenseAnalytics.monthlyCategories.isNotEmpty
                      ? ((expenseAnalytics.monthlyCategories.first.amount /
                                    expenseAnalytics.currentMonthExpense) *
                                100)
                            .clamp(0, 100)
                            .toDouble()
                      : 0,
                  budgetItems: expenseAnalytics.monthlyCategories.take(3).map((
                    cat,
                  ) {
                    final totalExpense = expenseAnalytics.currentMonthExpense;
                    final pct = totalExpense > 0
                        ? ((cat.amount / totalExpense) * 100)
                              .clamp(0, 100)
                              .toDouble()
                        : cat.percentage;
                    return BudgetStatusItem(
                      categoryName: cat.name,
                      percentage: pct,
                      color: cat.color,
                    );
                  }).toList(),
                  onBudgetTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BudgetManagementScreen(),
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
}
