import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
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
import 'package:expense_tracker/features/dashboard/widgets/budget_summary_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_budget_status.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_recent_activity.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_shortcuts_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_spending_categories.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_stat_card.dart';
import 'package:expense_tracker/features/reports/pages/view_reports_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/total_balance_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    final budgetProvider = context.watch<BudgetProvider>();

    final double totalBalance = balanceProvider.allTimeTotalBalance;
    final String currentMonthName = DateFormat('MMMM').format(DateTime.now());
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Income and Expense Card
              Skeletonizer(
                enabled: isLoading,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DashboardStatCard(
                          title:
                              '${context.translate('income')} ($currentMonthName)',
                          value: PrivacyMaskedText(
                            amount: txProvider.calendarMonthIncome,
                            style: AppTextStyles.cardValueGreen.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          isPositive: txProvider.isCalendarIncomeTrendGood,
                          isTrend: false,
                          centerText: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const IncomeInsightsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardStatCard(
                          title:
                              '${context.translate('expense')} ($currentMonthName)',
                          value: PrivacyMaskedText(
                            amount: txProvider.calendarMonthExpense,
                            style: AppTextStyles.cardValueRed.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          isPositive: txProvider.isCalendarExpenseTrendGood,
                          isTrend: false,
                          centerText: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExpenseInsightsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Row 2: To Receive and To Give Card
              Skeletonizer(
                enabled: isLoading,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DashboardStatCard(
                          title: context.translate('to_receive'),
                          value: PrivacyMaskedText(
                            amount: debtProvider.totalToReceive,
                            style: AppTextStyles.cardValueGreen.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          statusText: Text(
                            '${debtProvider.toReceiveUnpaid.length} ${context.translate('pending')}',
                            style: AppTextStyles.cardStatusText.copyWith(
                              fontSize: 10.5,
                            ),
                          ),
                          isPositive: true,
                          isTrend: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ToReceiveScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardStatCard(
                          title: context.translate('to_give'),
                          value: PrivacyMaskedText(
                            amount: debtProvider.totalToGive,
                            style: AppTextStyles.cardValueRed.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          statusText: Text(
                            '${debtProvider.toGiveUnpaid.length} ${context.translate('pending')}',
                            style: AppTextStyles.cardStatusText.copyWith(
                              fontSize: 10.5,
                            ),
                          ),
                          isPositive: false,
                          isTrend: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ToGiveScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Row 3: Total Balance and Reports Card
              Skeletonizer(
                enabled: isLoading,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DashboardStatCard(
                          title:
                              '${context.translate('cash')} & ${context.translate('bank')}',
                          value: Text(
                            context.translate('total_balance'),
                            style: AppTextStyles.cardValueGreen.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          statusText: PrivacyMaskedText(
                            amount: totalBalance,
                            style: AppTextStyles.cardStatusText.copyWith(
                              fontSize: 10.5,
                            ),
                          ),
                          isPositive: true,
                          isTrend: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TotalBalanceScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardStatCard(
                          title: 'Transactions, Parties, In...',
                          value: Text(
                            context.translate('reports'),
                            style: AppTextStyles.cardValueGreen.copyWith(
                              fontSize: 17,
                            ),
                          ),
                          isPositive: true,
                          isTrend: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ViewReportsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Skeletonizer(
                enabled: isLoading,
                child: BudgetSummaryCard(
                  monthlyExpense: txProvider.monthlyExpense,
                ),
              ),
              const SizedBox(height: 12),
              const DashboardShortcutsCard(),
              const SizedBox(height: 12),
              if (isLoading)
                _recentActivitySkeleton(context)
              else
                DashboardRecentActivity(
                  items: txProvider.transactions.take(5).map((tx) {
                    return RecentActivityItem(
                      title: tx.note.isEmpty ? tx.category : tx.note,
                      category: tx.category,
                      timeText: _getRelativeTime(tx.dateTime),
                      amount: tx.amount,
                      isIncome: tx.isIncome,
                      icon: _getCategoryIcon(tx.category),
                      transaction: tx,
                    );
                  }).toList(),
                  onViewAllTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecentActivityScreen(),
                      ),
                    );
                  },
                  onItemTap: (item) {
                    final tx = item.transaction;
                    if (tx != null) {
                      AddTransactionSheet.show(
                        context: context,
                        isIncome: tx.isIncome,
                        transaction: tx,
                      );
                    }
                  },
                ),
              const SizedBox(height: 12),
              DashboardSpendingCategories(
                categoryName: expenseAnalytics.monthlyCategories.isNotEmpty
                    ? expenseAnalytics.monthlyCategories.first.name
                    : 'No Expenses',
                percentage: expenseAnalytics.monthlyCategories.isNotEmpty
                    ? ((expenseAnalytics.monthlyCategories.first.amount /
                                  expenseAnalytics.currentMonthExpense) *
                              100)
                          .clamp(0, 100)
                          .toDouble()
                    : 0,
              ),
              const SizedBox(height: 12),
              DashboardBudgetStatus(
                items: expenseAnalytics.monthlyCategories.take(3).map((cat) {
                  final pct = budgetProvider.hasBudget
                      ? ((cat.amount / budgetProvider.amount) * 100)
                            .clamp(0, 100)
                            .toDouble()
                      : ((cat.amount / expenseAnalytics.currentMonthExpense) *
                                100)
                            .clamp(0, 100)
                            .toDouble();
                  return BudgetStatusItem(
                    categoryName: cat.name,
                    percentage: pct,
                    color: cat.color,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return Symbols.restaurant;
      case 'income':
      case 'salary':
        return Symbols.payments;
      case 'transport':
      case 'fuel':
      case 'travel':
        return Symbols.directions_car;
      case 'shopping':
      case 'clothing':
      case 'electronics':
        return Symbols.shopping_bag;
      case 'entertainment':
      case 'movie':
        return Symbols.movie;
      case 'utilities':
      case 'bills':
      case 'rent':
        return Symbols.receipt_long;
      case 'health':
      case 'medical':
        return Symbols.local_hospital;
      case 'education':
      case 'school':
        return Symbols.school;
      case 'transfer':
        return Symbols.swap_horiz;
      default:
        return Symbols.receipt_long;
    }
  }
}

Widget _recentActivitySkeleton(BuildContext context) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'View All',
              style: GoogleFonts.workSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Skeletonizer(
        enabled: true,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 11.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Title',
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Category  •  Today',
                            style: GoogleFonts.workSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+৳0,000',
                      style: GoogleFonts.workSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    ],
  );
}
