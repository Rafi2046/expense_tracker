import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class IncomeExpenseSummaryCard extends StatelessWidget {
  const IncomeExpenseSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final data = reportsProvider.incomeExpenseData;
    final currencySymbol = context.currencySymbol;

    final double totalIncome = data['totalIncome'] ?? 0.0;
    final double totalExpense = data['totalExpense'] ?? 0.0;
    final double netProfit = data['netProfit'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            netProfit >= 0 ? 'Net Profit' : 'Net Loss',
            style: AppTextStyles.reportStatLabel,
          ),
          const SizedBox(height: 6),
          Text(
            '$currencySymbol ${netProfit.abs().toStringAsFixed(0)}',
            style: AppTextStyles.reportLargeValue.copyWith(
              color: netProfit >= 0 ? AppColors.activeGreen : AppColors.activeRed,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Income',
                      style: AppTextStyles.reportStatLabel,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currencySymbol ${totalIncome.toStringAsFixed(0)}',
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade100),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expense',
                      style: AppTextStyles.reportStatLabel,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currencySymbol ${totalExpense.toStringAsFixed(0)}',
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        color: AppColors.activeRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
