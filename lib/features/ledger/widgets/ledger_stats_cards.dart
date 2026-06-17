import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LedgerStatsCards extends StatelessWidget {
  const LedgerStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencySymbol = context.currencySymbol;
    
    final totalIncome = provider.monthlyIncome;
    final totalExpense = provider.monthlyExpense;
    final netBalance = provider.monthlyNetBalance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Income Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.p16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.br12),
                  border: Border.all(
                    color: const Color(0xFFF1F1F1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Income',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_downward_rounded,
                          color: AppColors.activeGreen,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currencySymbol ${context.formatValueWithoutSymbol(totalIncome)}',
                      style: GoogleFonts.workSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Expense Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.p16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.br12),
                  border: Border.all(
                    color: const Color(0xFFF1F1F1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Expense',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.expensePink,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currencySymbol ${context.formatValueWithoutSymbol(totalExpense)}',
                      style: GoogleFonts.workSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.expensePink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),

        // Net Balance Summary Text
        Row(
          children: [
            Text(
              'Net Balance: ',
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.loginSubTitle,
              ),
            ),
            Text(
              '${netBalance >= 0 ? '' : '- '}$currencySymbol ${context.formatValueWithoutSymbol(netBalance.abs())}',
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
