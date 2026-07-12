import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';

class InvoiceTotalBadgeWidget extends StatelessWidget {
  final double totalSpent;
  final String currency;
  final bool isDark;

  const InvoiceTotalBadgeWidget({
    super.key,
    required this.totalSpent,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.activeGreen.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SPENT',
            style: GoogleFonts.jetBrainsMono(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF6B7280),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatAmount(totalSpent, currency),
            style: GoogleFonts.jetBrainsMono(
              fontSize: AppFontSizes.size36,
              fontWeight: FontWeight.w800,
              color: AppColors.activeGreen,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
