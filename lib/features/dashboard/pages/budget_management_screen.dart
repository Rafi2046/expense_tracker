import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_category_progress_list.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_management_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/set_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetManagementScreen extends StatelessWidget {
  const BudgetManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseAnalytics = context.watch<ExpenseAnalyticsProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);

    final categories = expenseAnalytics.monthlyCategories;
    final totalExpense = expenseAnalytics.currentMonthExpense;
    final hasBudget = budgetProvider.hasBudget;
    final budgetAmount = budgetProvider.amount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 8,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.p4),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Symbols.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
        leadingWidth: 56,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget',
              style: AppTextStyles.insightsHeaderTitle.copyWith(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Monthly overview',
              style: AppTextStyles.cardStatusText.copyWith(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C4E3C), Color(0xFF146C48)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.p16,
          AppSpacing.p4,
          AppSpacing.p16,
          AppSpacing.p24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BudgetManagementHeader(
              monthlyExpense: totalExpense,
              budgetAmount: budgetAmount,
              hasBudget: hasBudget,
              onEditBudget: () => _showSetBudgetDialog(context),
            ),
            const SizedBox(height: AppSpacing.s24),
            BudgetCategoryProgressList(
              items: categories
                  .map(
                    (cat) => BudgetCategoryItem(
                      name: cat.name,
                      amount: cat.amount,
                      percentage: cat.percentage,
                      color: cat.color,
                    ),
                  )
                  .toList(),
              totalExpense: totalExpense,
              hasBudget: hasBudget,
              budgetAmount: budgetAmount,
            ),
            if (!txProvider.isLoading && categories.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.h48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Symbols.receipt_long,
                        size: 48,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        'Add some expenses to see your budget breakdown',
                        style: AppTextStyles.cardStatusText,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) async {
    final provider = context.read<BudgetProvider>();
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => SetBudgetDialog(currentAmount: provider.amount),
    );
    if (amount != null) {
      provider.setBudget(amount);
    }
  }
}
