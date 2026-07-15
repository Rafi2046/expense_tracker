import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_item.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_chart.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_list.dart';

class ExpenseCategoriesBreakdownCard extends StatefulWidget {
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
  State<ExpenseCategoriesBreakdownCard> createState() =>
      _ExpenseCategoriesBreakdownCardState();
}

class _ExpenseCategoriesBreakdownCardState
    extends State<ExpenseCategoriesBreakdownCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final showExpandButton = widget.categories.length > 3;
    final displayList = (_isExpanded || !showExpandButton)
        ? widget.categories
        : widget.categories.take(3).toList();

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
          CategoryBreakdownHeader(suffixText: widget.suffixText),
          const SizedBox(height: 16),
          Row(
            children: [
              CategoryBreakdownChart(
                categories: widget.categories,
                totalAmount: widget.totalAmount,
              ),
              const SizedBox(width: 14),
              CategoryBreakdownList(
                categories: displayList,
                isDark: isDark,
                onSurface: onSurface,
              ),
            ],
          ),
          if (showExpandButton) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isExpanded ? context.translate('view_less') : context.translate('view_all_categories'),
                  style: TextStyle(
                    fontSize: AppFontSizes.size13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.activeGreen,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
