import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';

class BudgetCategoryItem {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  BudgetCategoryItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class BudgetCategoryProgressList extends StatelessWidget {
  final List<BudgetCategoryItem> items;
  final double totalExpense;
  final bool hasBudget;
  final double budgetAmount;

  const BudgetCategoryProgressList({
    super.key,
    required this.items,
    required this.totalExpense,
    required this.hasBudget,
    required this.budgetAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.h40),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'No expenses this month',
                style: AppTextStyles.cardStatusText,
              ),
            ],
          ),
        ),
      );
    }

    final currency = context.currencySymbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CATEGORY BREAKDOWN', style: AppTextStyles.cardTitle),
              Text(
                '${currency} ${_formatAmount(totalExpense)}',
                style: AppTextStyles.cardStatusText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        ...items.map(
          (item) => _CategoryProgressRow(
            item: item,
            totalExpense: totalExpense,
            hasBudget: hasBudget,
            budgetAmount: budgetAmount,
            currency: currency,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000)
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k';
    return amount.toStringAsFixed(0);
  }
}

class _CategoryProgressRow extends StatelessWidget {
  final BudgetCategoryItem item;
  final double totalExpense;
  final bool hasBudget;
  final double budgetAmount;
  final String currency;

  const _CategoryProgressRow({
    required this.item,
    required this.totalExpense,
    required this.hasBudget,
    required this.budgetAmount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pctDenom =
        hasBudget && budgetAmount > 0 ? budgetAmount : totalExpense;
    final barValue =
        pctDenom > 0 ? (item.amount / pctDenom).clamp(0.0, 1.0) : 0.0;
    final barPct = barValue * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.br8),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.borderColor.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : item.color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: AppTextStyles.reportTileTitle.copyWith(
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.s2),
                                Text(
                                  '${item.percentage.toStringAsFixed(1)}% of total',
                                  style: AppTextStyles.cardStatusText.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${currency} ${_formatAmount(item.amount)}',
                                style: AppTextStyles.reportTileTitle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s2),
                              Text(
                                '${barPct.toStringAsFixed(1)}% ${hasBudget ? "of budget" : "of spending"}',
                                style: AppTextStyles.cardStatusText.copyWith(
                                  fontSize: 11,
                                  color: item.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: barValue,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : item.color.withValues(alpha: 0.12),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(item.color),
                        ),
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

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    }
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
