import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class TourExpenseTile extends StatelessWidget {
  final ThemeData theme;
  final TourExpense expense;
  final String payerName;
  final Color avatarColor;
  final int includedCount;
  final String Function(double) formatAmount;
  final VoidCallback onTap;

  const TourExpenseTile({
    super.key,
    required this.theme,
    required this.expense,
    required this.payerName,
    required this.avatarColor,
    required this.includedCount,
    required this.formatAmount,
    required this.onTap,
  });

  String _splitLabel() {
    switch (expense.splitType) {
      case 'equal':
        return 'Split equally among $includedCount';
      case 'exact':
        return 'Split by exact amounts';
      case 'percentage':
        return 'Split by percentages';
      case 'exclusion':
        return 'Split among $includedCount (exclusions)';
      default:
        return 'Split equally among $includedCount';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final formattedDate = DateFormat('dd MMM').format(expense.date);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: avatarColor,
                  child: Text(
                    payerName.isNotEmpty ? String.fromCharCode(payerName.runes.first).toUpperCase() : '?',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.reportTileTitle.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${payerName.split(' ').first} \u00B7 ${_splitLabel()} \u00B7 $formattedDate',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatAmount(expense.amount),
                  style: AppTextStyles.h3.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
