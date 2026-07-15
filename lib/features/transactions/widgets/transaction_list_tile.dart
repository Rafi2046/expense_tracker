import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/category_utils.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class TransactionListTile extends StatelessWidget {
  final String title;
  final String dateText;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? incomeMonth;
  final bool isMasked;

  const TransactionListTile({
    super.key,
    required this.title,
    required this.dateText,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.onTap,
    this.onDelete,
    this.incomeMonth,
    this.isMasked = false,
  });

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.runes.isNotEmpty ? String.fromCharCode(text.runes.first).toUpperCase() + text.substring(1) : text;
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = isIncome ? AppColors.activeGreen : AppColors.expensePink;
    final amountPrefix = isIncome ? '+ ' : '- ';
    final catIcon = CategoryUtils.getIcon(category);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            children: [
              Icon(
                catIcon,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toTitleCase(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title.isNotEmpty ? '$title  •  $dateText' : dateText,
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amountPrefix,
                style: AppTextStyles.reportTransactionTitle.copyWith(
                  color: amountColor,
                ),
              ),
              PrivacyMaskedText(
                amount: amount,
                isMasked: isMasked,
                style: AppTextStyles.reportTransactionTitle.copyWith(
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
