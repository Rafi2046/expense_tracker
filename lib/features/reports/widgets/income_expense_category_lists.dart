import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/model/category_summary.dart';

class IncomeExpenseCategoryLists extends StatelessWidget {
  const IncomeExpenseCategoryLists({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final data = reportsProvider.incomeExpenseData;
    final currencySymbol = context.currencySymbol;

    final List<CategorySummary> incomeSummaries = List<CategorySummary>.from(data['incomeSummaries'] ?? []);
    final List<CategorySummary> expenseSummaries = List<CategorySummary>.from(data['expenseSummaries'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Incomes by Category
        if (incomeSummaries.isNotEmpty) ...[
          Text(
            'Incomes by Category',
            style: AppTextStyles.reportTransactionTitle,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F1F1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: incomeSummaries.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF8FAFC), height: 1),
              itemBuilder: (context, index) {
                final s = incomeSummaries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    s.categoryName,
                    style: AppTextStyles.reportTransactionTitle,
                  ),
                  subtitle: Text(
                    '${s.transactionCount} transactions',
                    style: AppTextStyles.reportTransactionSubtitle,
                  ),
                  trailing: Text(
                    '$currencySymbol ${s.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      color: AppColors.activeGreen,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Expenses by Category
        if (expenseSummaries.isNotEmpty) ...[
          Text(
            'Expenses by Category',
            style: AppTextStyles.reportTransactionTitle,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F1F1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenseSummaries.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFFF8FAFC), height: 1),
              itemBuilder: (context, index) {
                final s = expenseSummaries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    s.categoryName,
                    style: AppTextStyles.reportTransactionTitle,
                  ),
                  subtitle: Text(
                    '${s.transactionCount} transactions',
                    style: AppTextStyles.reportTransactionSubtitle,
                  ),
                  trailing: Text(
                    '$currencySymbol ${s.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      color: AppColors.activeRed,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
