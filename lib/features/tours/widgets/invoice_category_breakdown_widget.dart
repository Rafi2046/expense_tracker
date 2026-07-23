import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class InvoiceCategoryBreakdownWidget extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final String currency;
  final bool isDark;

  const InvoiceCategoryBreakdownWidget({
    super.key,
    required this.categoryTotals,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: sorted.map((e) {
          final pct = total > 0 ? e.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.p12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                      ),
                    ),
                    Text(
                      formatAmount(e.value, currency),
                      style: AppTextStyles.bodySmall.copyWith(fontFamily: GoogleFonts.jetBrainsMono().fontFamily, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                    color: AppColors.activeGreen,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
