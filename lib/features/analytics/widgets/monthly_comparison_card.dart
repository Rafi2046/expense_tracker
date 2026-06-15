import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyComparisonCard extends StatelessWidget {
  final double currentAmount;
  final double previousAmount;
  final String netChangeText;

  const MonthlyComparisonCard({
    super.key,
    required this.currentAmount,
    required this.previousAmount,
    required this.netChangeText,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress values relative to the maximum of the two amounts to prevent overflow.
    final maxAmount = currentAmount > previousAmount ? currentAmount : previousAmount;
    final currentProgress = maxAmount > 0 ? currentAmount / maxAmount : 0.0;
    final previousProgress = maxAmount > 0 ? previousAmount / maxAmount : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Monthly Comparison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This Month vs Last Month',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
          const SizedBox(height: 20),

          // Current Month Row Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Month',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF31394D),
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Text(
                '\$${currentAmount.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Current Month Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: currentProgress,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.activeGreen),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Previous Month Row Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Previous Month',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF31394D),
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Text(
                '\$${previousAmount.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Previous Month Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: previousProgress,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB3C5B9)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(
            color: AppColors.dividerColor.withValues(alpha: 0.3),
            height: 1.0,
          ),
          const SizedBox(height: 16),

          // Net Change Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Change',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF31394D),
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: AppColors.activeRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    netChangeText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeRed,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
