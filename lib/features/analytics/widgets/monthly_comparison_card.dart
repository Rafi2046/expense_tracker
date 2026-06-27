import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/analytics/widgets/comparison_progress_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MonthlyComparisonCard extends StatelessWidget {
  final double currentAmount;
  final double previousAmount;
  final String netChangeText;
  final bool isMasked;

  const MonthlyComparisonCard({
    super.key,
    required this.currentAmount,
    required this.previousAmount,
    required this.netChangeText,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxAmount = currentAmount > previousAmount ? currentAmount : previousAmount;
    final currentProgress = maxAmount > 0 ? currentAmount / maxAmount : 0.0;
    final previousProgress = maxAmount > 0 ? previousAmount / maxAmount : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Comparison',
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'This Month vs Last Month',
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),

          ComparisonProgressRow(
            label: 'Current Month',
            amount: currentAmount,
            progress: currentProgress,
            progressColor: AppColors.activeGreen,
            isMasked: isMasked,
          ),
          const SizedBox(height: 14),

          ComparisonProgressRow(
            label: 'Previous Month',
            amount: previousAmount,
            progress: previousProgress,
            progressColor: isDark ? Colors.grey.shade700 : const Color(0xFFB3C5B9),
            isMasked: isMasked,
          ),
          const SizedBox(height: 16),

          Divider(
            color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
            height: 1,
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Change',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : const Color(0xFF4A5568),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Symbols.trending_up,
                    color: AppColors.activeRed,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    netChangeText,
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.activeRed,
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
