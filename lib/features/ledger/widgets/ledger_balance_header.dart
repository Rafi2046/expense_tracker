import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerBalanceHeader extends StatelessWidget {
  final String balance;
  final String trendPercentage;

  const LedgerBalanceHeader({
    super.key,
    required this.balance,
    required this.trendPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Label
        Text(
          context.translate('total_balance').toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.loginSubTitle.withValues(alpha: 0.8),
            fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),

        // Balance & Trend Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              balance,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trendPercentage,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.activeGreen,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
