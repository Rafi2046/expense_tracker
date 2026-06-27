import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LedgerStatsCards extends StatelessWidget {
  final bool isMasked;
  final VoidCallback onToggleMask;

  const LedgerStatsCards({
    super.key,
    required this.isMasked,
    required this.onToggleMask,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final totalIncome = provider.monthlyIncome;
    final totalExpense = provider.monthlyExpense;
    final netBalance = provider.monthlyNetBalance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF32235B),
            Color(0xFF6A53A1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A53A1).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.translate('total_balance').toUpperCase(),
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  provider.selectedMonth.year.toString(),
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggleMask();
                },
                child: Icon(
                  isMasked ? Symbols.visibility_off : Symbols.visibility,
                  size: 20,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Net Balance Value
          PrivacyMaskedText(
            amount: netBalance,
            isMasked: isMasked,
            style: GoogleFonts.workSans(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 12),

          // Income vs Expense row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_downward_rounded,
                        color: Color(0xFF2ECC71),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('income'),
                            style: GoogleFonts.workSans(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          PrivacyMaskedText(
                            amount: totalIncome,
                            isMasked: isMasked,
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_upward_rounded,
                        color: Color(0xFFF1948A),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('expense'),
                            style: GoogleFonts.workSans(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          PrivacyMaskedText(
                            amount: totalExpense,
                            isMasked: isMasked,
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
