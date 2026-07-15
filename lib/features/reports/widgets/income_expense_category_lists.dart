import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/model/category_summary.dart';

class IncomeExpenseCategoryLists extends StatelessWidget {
  final bool isMasked;

  const IncomeExpenseCategoryLists({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final data = reportsProvider.incomeExpenseData;
    final theme = Theme.of(context);

    final List<CategorySummary> incomeSummaries = List<CategorySummary>.from(data['incomeSummaries'] ?? []);
    final List<CategorySummary> expenseSummaries = List<CategorySummary>.from(data['expenseSummaries'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (incomeSummaries.isNotEmpty) ...[
          Text(
            context.translate('incomes_by_category'),
            style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: incomeSummaries.length,
              separatorBuilder: (context, index) => Divider(color: theme.dividerTheme.color ?? const Color(0xFFF8FAFC), height: 1),
              itemBuilder: (context, index) {
                final s = incomeSummaries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    s.categoryName,
                    style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    context.translate('transaction_count_plural', namedArgs: {'count': s.transactionCount.toString()}),
                    style: AppTextStyles.reportTransactionSubtitle.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: PrivacyMaskedText(
                    amount: s.totalAmount,
                    isMasked: isMasked,
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        if (expenseSummaries.isNotEmpty) ...[
          Text(
            context.translate('expenses_by_category'),
            style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenseSummaries.length,
              separatorBuilder: (context, index) => Divider(color: theme.dividerTheme.color ?? const Color(0xFFF8FAFC), height: 1),
              itemBuilder: (context, index) {
                final s = expenseSummaries[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  title: Text(
                    s.categoryName,
                    style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    context.translate('transaction_count_plural', namedArgs: {'count': s.transactionCount.toString()}),
                    style: AppTextStyles.reportTransactionSubtitle.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: PrivacyMaskedText(
                    amount: s.totalAmount,
                    isMasked: isMasked,
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
