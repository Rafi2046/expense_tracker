import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/utils/category_utils.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

class CategoryDetailCard extends StatelessWidget {
  final String category;

  const CategoryDetailCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catColor = CategoryUtils.getColor(category);
    final catIcon = CategoryUtils.getIcon(category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(catIcon, color: catColor, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            category,
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size15,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

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
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                context.formatAmount(transaction.amount),
                style: GoogleFonts.workSans(
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
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  Text(
                    transaction.paymentMethod,
                    style: GoogleFonts.workSans(
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

class MemoDetailCard extends StatelessWidget {
  final String note;

  const MemoDetailCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
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
            'Memo / Detail',
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size14,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
            : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.cloud,
            color: isDark ? Colors.white38 : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Entry is synced successfully!',
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size12,
                color: isDark ? Colors.white60 : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
