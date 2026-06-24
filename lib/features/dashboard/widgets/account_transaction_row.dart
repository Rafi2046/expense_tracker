import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/pages/transaction_details_screen.dart';

class AccountTransactionRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool showBalances;

  const AccountTransactionRow({
    super.key,
    required this.item,
    required this.showBalances,
  });

  String _formatAmount(double val) {
    final formatted = (val % 1 == 0)
        ? val
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )
        : val
              .toStringAsFixed(2)
              .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              );
    return 'Tk. $formatted';
  }

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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1.2),
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
                content: Text('Debt detail: $title - ${_formatAmount(amount)}'),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? const Color(0xFF2EBD85)
                          : const Color(0xFFDC3545),
                    ),
                  ),
                  Text(
                    '$amountPrefix${_formatAmount(amount)}',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F3EE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Bal: ${showBalances ? _formatAmount(runningBal) : "Tk. ••••"}',
                      style: GoogleFonts.workSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF006C49),
                      ),
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
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    category,
                    style: GoogleFonts.workSans(
                      fontSize: 10.5,
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
