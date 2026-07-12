import 'package:flutter/material.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_spending_categories.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_budget_status.dart';

class DashboardSummaryFooter extends StatelessWidget {
  final String topCategoryName;
  final double topCategoryPercentage;
  final List<BudgetStatusItem> budgetItems;
  final VoidCallback onBudgetTap;

  const DashboardSummaryFooter({
    super.key,
    required this.topCategoryName,
    required this.topCategoryPercentage,
    required this.budgetItems,
    required this.onBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardSpendingCategories(
          categoryName: topCategoryName,
          percentage: topCategoryPercentage,
        ),
        const SizedBox(height: 8),
        DashboardBudgetStatus(
          onTap: onBudgetTap,
          items: budgetItems,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
