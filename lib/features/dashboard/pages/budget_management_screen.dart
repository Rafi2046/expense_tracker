import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/budget_provider.dart';
import 'package:expense_tracker/core/providers/expense_analytics_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_category_progress_list.dart';
import 'package:expense_tracker/features/dashboard/widgets/budget_management_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/set_budget_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BudgetManagementScreen extends StatelessWidget {
  const BudgetManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseAnalytics = context.watch<ExpenseAnalyticsProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final theme = Theme.of(context);

    final isLoading = txProvider.isLoading || budgetProvider.isLoading;
    final categories = expenseAnalytics.monthlyCategories;
    final totalExpense = expenseAnalytics.currentMonthExpense;
    final hasBudget = budgetProvider.hasBudget;
    final budgetAmount = budgetProvider.amount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text(
          context.translate('budget_management'),
          style: AppTextStyles.reportAppBarTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.p16,
          AppSpacing.p4,
          AppSpacing.p16,
          AppSpacing.p24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Skeletonizer(
          enabled: isLoading,
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
              if (!isLoading && categories.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.h48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.receipt,
                        size: 48,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        context.translate('add_expenses_to_see_budget'),
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
