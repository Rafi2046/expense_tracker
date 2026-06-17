import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
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
    final amountColor = isIncome ? AppColors.activeGreen : AppColors.expensePink;
    final amountPrefix = isIncome ? '+ ' : '- ';
    
    final formattedAmount = (amount % 1 == 0)
        ? amount.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : amount.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.br12),
        border: Border.all(
          color: const Color(0xFFF1F1F1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.br12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Title & Subtitle (Date + Category)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$dateText  •  $category',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Section: Amount
              Text(
                '$amountPrefix${context.currencySymbol} $formattedAmount',
                style: GoogleFonts.workSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
