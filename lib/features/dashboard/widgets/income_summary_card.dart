import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncomeSummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final String? percentageText;
  final String? compareText;
  final Widget? bottomContent;
  final bool showDivider;

  const IncomeSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    this.percentageText,
    this.compareText,
    this.bottomContent,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.summaryCardLabel),
          const SizedBox(height: 8),
          Text(amount, style: AppTextStyles.summaryCardValue),
          if (percentageText != null && compareText != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.selectionGreenBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    percentageText!,
                    style: AppTextStyles.summaryCardTrendText,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  compareText!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.loginSubTitle,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
              ],
            ),
          ] else if (percentageText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppColors.activeGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  percentageText!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.activeGreen,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
              ],
            ),
          ],
          if (showDivider) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: AppColors.dividerColor.withValues(alpha: 0.5),
            ),
          ],
          if (bottomContent != null) ...[
            const SizedBox(height: 16),
            bottomContent!,
          ],
        ],
      ),
    );
  }
}
