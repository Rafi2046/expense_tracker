import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
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
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.id.length > 5
                      ? transaction.id.substring(transaction.id.length - 4)
                      : transaction.id,
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
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
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd Jun yyyy').format(transaction.dateTime),
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
