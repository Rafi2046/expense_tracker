import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';

class TransactionFilters extends StatelessWidget {
  final TransactionTypeFilter selectedFilter;
  final bool isDark;
  final ValueChanged<TransactionTypeFilter> onFilterChanged;

  const TransactionFilters({
    super.key,
    required this.selectedFilter,
    required this.isDark,
    required this.onFilterChanged,
  });

  Widget _buildSegment(String label, TransactionTypeFilter filter) {
    final isSelected = selectedFilter == filter;
    Color selectedColor;
    switch (filter) {
      case TransactionTypeFilter.income:
        selectedColor = AppColors.activeGreen;
      case TransactionTypeFilter.expense:
        selectedColor = AppColors.expensePink;
      case TransactionTypeFilter.all:
        selectedColor = const Color(0xFF6A53A1);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: AppFontSizes.size13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildSegment('All', TransactionTypeFilter.all),
          const SizedBox(width: 4),
          _buildSegment('Income', TransactionTypeFilter.income),
          const SizedBox(width: 4),
          _buildSegment('Expense', TransactionTypeFilter.expense),
        ],
      ),
    );
  }
}
