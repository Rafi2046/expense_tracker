import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TransactionInfoRow extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionInfoRow({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isIncome = transaction.isIncome;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              border: Border.all(
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                    : const Color(0xFFF1F1F1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIncome ? 'Income Number' : 'Expense Number',
                  style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  transaction.id.length > 5
                      ? transaction.id.substring(transaction.id.length - 4)
                      : transaction.id,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.r8),
              border: Border.all(
                color: isDark
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                    : const Color(0xFFF1F1F1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  DateFormat('dd Jun yyyy').format(transaction.dateTime),
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
