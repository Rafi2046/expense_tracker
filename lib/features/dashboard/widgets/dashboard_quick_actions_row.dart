import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_summary_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/dashboard_shortcuts_card.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DashboardQuickActionsRow extends StatelessWidget {
  final bool isLoading;
  final double monthlyExpense;

  const DashboardQuickActionsRow({
    super.key,
    required this.isLoading,
    required this.monthlyExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Skeletonizer(
          enabled: isLoading,
          child: BudgetSummaryCard(monthlyExpense: monthlyExpense),
        ),
        const SizedBox(height: AppSpacing.s8),
        const DashboardShortcutsCard(),
        const SizedBox(height: AppSpacing.s8),
      ],
    );
  }
}
