import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WeeklyComparisonBadge extends StatelessWidget {
  final double total;
  final double previousTotal;

  const WeeklyComparisonBadge({
    super.key,
    required this.total,
    required this.previousTotal,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0 && previousTotal == 0) return const SizedBox.shrink();

    final diff = total - previousTotal;
    final isDecrease = diff < 0;

    if (diff == 0) return const SizedBox.shrink();

    final double percent = previousTotal > 0
        ? (diff.abs() / previousTotal * 100)
        : 100.0;

    final badgeColor = isDecrease ? AppColors.activeGreen : AppColors.activeRed;
    final bgColor = badgeColor.withValues(alpha: 0.12);
    final arrowIcon = isDecrease ? LucideIcons.trendingDown : LucideIcons.trendingUp;
    final label = "${isDecrease ? '-' : '+'}${percent.toStringAsFixed(1)}% ${context.translate('versus_last_week')}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(arrowIcon, color: badgeColor, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
