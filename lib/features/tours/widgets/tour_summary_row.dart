import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class TourSummaryRow extends StatelessWidget {
  final String totalSpentText;
  final String outstandingText;
  final bool isSettled;

  const TourSummaryRow({
    super.key,
    required this.totalSpentText,
    required this.outstandingText,
    required this.isSettled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            theme: theme,
            label: 'Total spent',
            value: totalSpentText,
            icon: Icons.payments_outlined,
            iconColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
            iconBgColor: isDark ? const Color(0xFF1E1E3F) : const Color(0xFFEEF2FF),
            valueColor: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            theme: theme,
            label: isSettled ? 'All settled' : 'Outstanding',
            value: isSettled ? '✓' : outstandingText,
            icon: isSettled ? Icons.check_circle_outline_rounded : Icons.swap_horizontal_circle_outlined,
            iconColor: isSettled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            iconBgColor: isSettled
                ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFF1F2)),
            valueColor: isSettled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color valueColor,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: AppFontSizes.size10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
