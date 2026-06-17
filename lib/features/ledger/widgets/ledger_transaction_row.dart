import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerTransactionRow extends StatelessWidget {
  final String title;
  final String dateText;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final VoidCallback onTap;

  const LedgerTransactionRow({
    super.key,
    required this.title,
    required this.dateText,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Styling constants depending on income vs expense
    final iconBgColor = isIncome ? const Color(0xFFE8F8F5) : const Color(0xFFF2F4F4);
    final iconColor = isIncome ? AppColors.activeGreen : const Color(0xFF31394D);
    final amountColor = isIncome ? AppColors.activeGreen : AppColors.expensePink;
    final amountPrefix = isIncome ? '+${context.currencySymbol}' : '-${context.currencySymbol}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            // Category Icon inside container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Description column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateText  •  $category',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Section (Amount and Chevron)
            Row(
              children: [
                Text(
                  '$amountPrefix${amount.toStringAsFixed(2).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
