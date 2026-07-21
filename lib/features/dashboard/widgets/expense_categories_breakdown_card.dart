import 'package:flutter/material.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_item.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_list.dart';

class ExpenseCategoriesBreakdownCard extends StatelessWidget {
  final String suffixText;
  final Widget totalAmount;
  final List<CategoryBreakdownItem> categories;
  final bool isMasked;

  const ExpenseCategoriesBreakdownCard({
    super.key,
    required this.suffixText,
    required this.totalAmount,
    required this.categories,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryBreakdownHeader(suffixText: suffixText),
          const SizedBox(height: 16),
          Row(
            children: [
              CategoryBreakdownChart(
                categories: categories,
                totalAmount: totalAmount,
              ),
              const SizedBox(width: 14),
              CategoryBreakdownList(
                categories: categories,
                isDark: isDark,
                onSurface: onSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
