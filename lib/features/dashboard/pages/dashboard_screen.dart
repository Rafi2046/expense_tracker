import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/profile_manager_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
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
import 'package:expense_tracker/features/dashboard/pages/total_balance_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/budget_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;
    final debtProvider = context.watch<DebtProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final balanceProvider = context.watch<BalanceAnalyticsProvider>();
    final expenseAnalytics = context.watch<ExpenseAnalyticsProvider>();
    final double totalBalance = balanceProvider.allTimeTotalBalance;
    final String currentMonthName = context.formatMonth(DateTime.now());
    final isLoading = txProvider.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HomepageAppbarWidget(
        onProfileTap: () {
          ProfileSwitchSheet.show(
            context: context,
            currentProfileId: currentProfile.id,
            profiles: profileProvider.profiles,
            onProfileSelected: (selectedProfile) {
              profileProvider.selectProfile(selectedProfile);
              context.read<ProfileManagerProvider>().switchProfile(
                selectedProfile.id,
              );
            },
            onCreateNewTap: () async {
              final newProfile = await Navigator.push<UserProfile>(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectProfileScreen(),
                ),
              );
              if (newProfile != null && context.mounted) {
                context.read<ProfileManagerProvider>().switchProfile(
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
          await profileProvider.reload();
          txProvider.updateProfileId(profileProvider.currentProfile.id);
          debtProvider.updateProfileId(profileProvider.currentProfile.id);
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
                  toReceivePendingCount:
                      debtProvider.toReceiveUnpaid.length,
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
                const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                DashboardQuickActionsRow(
                  isLoading: isLoading,
                  monthlyExpense: txProvider.monthlyExpense,
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
                const SizedBox(height: 8),
                DashboardSummaryFooter(
                  topCategoryName:
                      expenseAnalytics.monthlyCategories.isNotEmpty
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
                  budgetItems:
                      expenseAnalytics.monthlyCategories.take(3).map((cat) {
                    final totalExpense =
                        expenseAnalytics.currentMonthExpense;
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
