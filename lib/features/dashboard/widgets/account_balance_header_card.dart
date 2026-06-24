import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/reports/pages/bank_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/cash_in_hand_statement_screen.dart';

class AccountBalanceHeaderCard extends StatelessWidget {
  final String accountType;
  final double balance;
  final bool showBalances;
  final VoidCallback onToggleBalances;

  const AccountBalanceHeaderCard({
    super.key,
    required this.accountType,
    required this.balance,
    required this.showBalances,
    required this.onToggleBalances,
  });

  String _formatAmount(double val) {
    final formatted = (val % 1 == 0)
        ? val.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : val.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
    return 'Tk. $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Current Balance',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onToggleBalances,
                    child: Icon(
                      showBalances ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                showBalances ? _formatAmount(balance) : 'Tk. ••••',
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF006C49),
                ),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => accountType == 'Cash'
                      ? const CashInHandStatementScreen()
                      : const BankStatementScreen(),
                ),
              );
            },
            icon: const Icon(Icons.description_outlined, size: 14, color: Color(0xFF006C49)),
            label: Text(
              'View Report',
              style: GoogleFonts.workSans(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF006C49),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE6F3EE)),
              backgroundColor: const Color(0xFFE6F3EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}
