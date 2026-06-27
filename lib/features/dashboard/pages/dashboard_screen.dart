import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:expense_tracker/features/dashboard/pages/expense_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/recent_activity_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/income_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/notifications_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/to_give_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/to_receive_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_summary_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_budget_status.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_recent_activity.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_shortcuts_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_spending_categories.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_stat_card.dart';
import 'package:expense_tracker/features/reports/pages/view_reports_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/total_balance_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final budgetProvider = context.watch<BudgetProvider>();

    final double totalBalance = balanceProvider.allTimeTotalBalance;
    final String currentMonthName = DateFormat('MMMM').format(DateTime.now());

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final localPhoto = user != null
            ? SharedPrefsHelper.getString('local_profile_photo_${user.uid}')
            : null;
        final photoUrl = localPhoto ?? user?.photoURL;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: HomepageAppbarWidget(
            name: currentProfile.name,
            profilePhoto: photoUrl,
            onProfileTap: () {
              ProfileSwitchSheet.show(
                context: context,
                currentProfileId: currentProfile.id,
                profiles: profileProvider.profiles,
                onProfileSelected: (selectedProfile) {
                  profileProvider.selectProfile(selectedProfile);
                },
                onCreateNewTap: () async {
                  final newProfile = await Navigator.push<UserProfile>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectProfileScreen(),
                    ),
                  );
                  if (newProfile != null) {
                    profileProvider.addProfile(newProfile);
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
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title:
                                '${context.translate('income')} ($currentMonthName)',
                            value: PrivacyMaskedText(
                              amount: txProvider.monthlyIncome,
                              style: AppTextStyles.cardValueGreen.copyWith(fontSize: 17),
                            ),
                            percentageText: '+12%',
                            isPositive: true,
                            isTrend: true,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardStatCard(
                            title:
                                '${context.translate('expense')} ($currentMonthName)',
                            value: PrivacyMaskedText(
                              amount: txProvider.monthlyExpense,
                              style: AppTextStyles.cardValueRed.copyWith(fontSize: 17),
                            ),
                            percentageText: '-5%',
                            isPositive: false,
                            isTrend: true,
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
                  const SizedBox(height: 16),

                  // Row 2: To Receive and To Give Card
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title: context.translate('to_receive'),
                            value: PrivacyMaskedText(
                              amount: debtProvider.totalToReceive,
                              style: AppTextStyles.cardValueGreen.copyWith(fontSize: 17),
                            ),
                            statusText: Text(
                              '${debtProvider.toReceiveUnpaid.length} ${context.translate('pending')}',
                              style: AppTextStyles.cardStatusText.copyWith(fontSize: 10.5),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardStatCard(
                            title: context.translate('to_give'),
                            value: PrivacyMaskedText(
                              amount: debtProvider.totalToGive,
                              style: AppTextStyles.cardValueRed.copyWith(fontSize: 17),
                            ),
                            statusText: Text(
                              '${debtProvider.toGiveUnpaid.length} ${context.translate('pending')}',
                              style: AppTextStyles.cardStatusText.copyWith(fontSize: 10.5),
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
                  const SizedBox(height: 16),

                  // Row 3: Total Balance and Reports Card
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title:
                                '${context.translate('cash')} & ${context.translate('bank')}',
                            value: Text(
                              context.translate('total_balance'),
                              style: AppTextStyles.cardValueGreen.copyWith(fontSize: 17),
                            ),
                            statusText: PrivacyMaskedText(
                              amount: totalBalance,
                              style: AppTextStyles.cardStatusText.copyWith(fontSize: 10.5),
                            ),
                            isPositive: true,
                            isTrend: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TotalBalanceScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardStatCard(
                            title: 'Transactions, Parties, In...',
                            value: Text(
                              context.translate('reports'),
                              style: AppTextStyles.cardValueGreen.copyWith(fontSize: 17),
                            ),
                            isPositive: true,
                            isTrend: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ViewReportsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BudgetSummaryCard(monthlyExpense: txProvider.monthlyExpense),
                  const SizedBox(height: 24),
                  const DashboardShortcutsCard(),
                  const SizedBox(height: 24),
                  DashboardRecentActivity(
                    items: txProvider.transactions.take(5).map((tx) {
                      return RecentActivityItem(
                        title: tx.note.isEmpty ? tx.category : tx.note,
                        category: tx.category,
                        timeText: _getRelativeTime(tx.dateTime),
                        amount: tx.amount,
                        isIncome: tx.isIncome,
                        icon: _getCategoryIcon(tx.category),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tapped activity: ${item.title}'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  DashboardBudgetStatus(
                    items: expenseAnalytics.monthlyCategories.take(3).map((cat) {
                      final pct = budgetProvider.hasBudget
                          ? ((cat.amount / budgetProvider.amount) * 100).clamp(0, 100).toDouble()
                          : ((cat.amount / expenseAnalytics.currentMonthExpense) * 100).clamp(0, 100).toDouble();
                      return BudgetStatusItem(
                        categoryName: cat.name,
                        percentage: pct,
                        color: cat.color,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
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
