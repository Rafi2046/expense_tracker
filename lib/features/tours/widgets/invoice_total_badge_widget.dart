import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16, horizontal: AppSpacing.p24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
          color: AppColors.activeGreen.withValues(alpha: isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SPENT',
            style: AppTextStyles.caption.copyWith(fontFamily: GoogleFonts.jetBrainsMono().fontFamily, fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF6B7280),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatAmount(totalSpent, currency),
              maxLines: 1,
              style: AppTextStyles.displayLarge.copyWith(
                fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                fontWeight: FontWeight.w800,
                color: AppColors.activeGreen,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
