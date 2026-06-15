import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/widgets/common_widgets/appbar_widget.dart';
import 'package:expense_tracker/core/widgets/common_widgets/user_profile_widget.dart';
import 'package:expense_tracker/features/dashboard/pages/expense_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/income_insights_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/select_profile_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_budget_status.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_recent_activity.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_shortcuts_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_spending_categories.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentProfile = profileProvider.currentProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: HomepageAppbarWidget(
        name: currentProfile.name,
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
        notificationOnTap: () {},
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.40,
                // Customizes card aspect ratio
                children: [
                  DashboardStatCard(
                    title: 'Income',
                    value: '\$5,240',
                    percentageText: '+12%',
                    isPositive: true,
                    isTrend: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IncomeInsightsScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardStatCard(
                    title: 'Expense',
                    value: '\$2,180',
                    percentageText: '-5%',
                    isPositive: false,
                    isTrend: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseInsightsScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardStatCard(
                    title: 'To Receive',
                    value: '\$850',
                    statusText: '3 pending',
                    isPositive: true,
                    isTrend: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('To Receive pending list clicked'),
                        ),
                      );
                    },
                  ),
                  DashboardStatCard(
                    title: 'To Give',
                    value: '\$320',
                    statusText: 'Due in 2 days',
                    isPositive: false,
                    isTrend: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('To Give due list clicked'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const DashboardShortcutsCard(),
              const SizedBox(height: 24),
              DashboardRecentActivity(
                items: [
                  RecentActivityItem(
                    title: 'Apple Store',
                    category: 'Electronics',
                    timeText: 'Today',
                    amount: 199.00,
                    isIncome: false,
                    icon: Icons.shopping_bag_outlined,
                  ),
                  RecentActivityItem(
                    title: 'Wild Ginger',
                    category: 'Food',
                    timeText: 'Yesterday',
                    amount: 42.50,
                    isIncome: false,
                    icon: Icons.restaurant,
                  ),
                  RecentActivityItem(
                    title: 'Monthly Salary',
                    category: 'Income',
                    timeText: '2 days ago',
                    amount: 4200.00,
                    isIncome: true,
                    icon: Icons.payments_outlined,
                  ),
                ],
                onViewAllTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recent Activity View All clicked')),
                  );
                },
                onItemTap: (item) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped activity: ${item.title}')),
                  );
                },
              ),
              const SizedBox(height: 20),
              const DashboardSpendingCategories(
                categoryName: 'Food',
                percentage: 42,
              ),
              const SizedBox(height: 20),
              DashboardBudgetStatus(
                items: [
                  BudgetStatusItem(
                    categoryName: 'Entertainment',
                    percentage: 80,
                    color: AppColors.expensePink,
                  ),
                  BudgetStatusItem(
                    categoryName: 'Utilities',
                    percentage: 45,
                    color: AppColors.activeGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
