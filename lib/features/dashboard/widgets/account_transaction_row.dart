import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/pages/transaction_details_screen.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AccountTransactionRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const AccountTransactionRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = item['isIncome'];
    final double amount = item['amount'];
    final double runningBal = item['runningBalance'];
    final String title = item['title'];
    final String category = item['category'];
    final DateTime dateTime = item['dateTime'];

    final amountColor = isIncome
        ? const Color(0xFF2EBD85)
        : const Color(0xFFDC3545);
    final amountPrefix = isIncome ? '+ ' : '- ';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          final rawItem = item['item'];
          if (rawItem is TransactionItem) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailsScreen(transaction: rawItem),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Debt detail: $title - ${context.formatAmount(amount, listen: false)}'),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Header Type badge & Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isIncome ? 'Income #1' : 'Expense #1',
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size10,
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? const Color(0xFF2EBD85)
                          : const Color(0xFFDC3545),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amountPrefix,
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size14,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      PrivacyMaskedText(
                        amount: amount,
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size14,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: Title & Running Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFE6F3EE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bal: ',
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                          ),
                        ),
                        PrivacyMaskedText(
                          amount: runningBal,
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3: Date/Time & Category Icon/Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy • h:mm a').format(dateTime),
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    category,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
