import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AmountPaymentDetailCard extends StatelessWidget {
  final TransactionItem transaction;

  const AmountPaymentDetailCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isIncome = transaction.isIncome;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : const Color(0xFFF1F1F1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.005),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: AppFontSizes.size14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                context.formatAmount(transaction.amount),
                style: TextStyle(
                  fontSize: AppFontSizes.size16,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFF006C49) : const Color(0xFFDC3545),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                : const Color(0xFFF1F1F1),
            height: 1,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Mode',
                style: TextStyle(
                  fontSize: AppFontSizes.size14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    transaction.paymentMethod,
                    style: TextStyle(
                      fontSize: AppFontSizes.size14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 10,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
