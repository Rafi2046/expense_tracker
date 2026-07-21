import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DailyInsightsCard extends StatelessWidget {
  final List<String> insights;

  const DailyInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22262E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                color: isDark ? const Color(0xFF8E75C8) : theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                context.translate('daily_insights'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSizes.size14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (insights.isEmpty)
            Text(
              context.translate('no_expenses_today'),
              style: TextStyle(
                fontSize: AppFontSizes.size12,
                color: isDark ? Colors.grey.shade400 : AppColors.textMuted,
              ),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(insights.length, (index) {
                final text = insights[index];
                final isLast = index == insights.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0.0 : 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF8E75C8) : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: AppFontSizes.size11,
                            color: isDark ? Colors.grey.shade300 : AppColors.loginSubTitle,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
