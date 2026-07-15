import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class TourDashboardStatsRow extends StatelessWidget {
  final int expenseCount;

  const TourDashboardStatsRow({super.key, required this.expenseCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Text(
            context.translate('expenses_count'),
            style: AppTextStyles.h2.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$expenseCount',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
