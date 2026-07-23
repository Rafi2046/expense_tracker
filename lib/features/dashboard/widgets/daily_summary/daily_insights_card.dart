import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class DailyInsightsCard extends StatelessWidget {
  final List<String> insights;
  final String titleKey;

  const DailyInsightsCard({
    super.key,
    required this.insights,
    this.titleKey = 'daily_insights',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22262E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.p16),
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
              const SizedBox(width: AppSpacing.s8),
              Text(
                context.translate(titleKey),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          if (insights.isEmpty)
            Text(
              context.translate(
                titleKey == 'monthly_insights'
                    ? 'no_expenses_this_month'
                    : 'no_expenses_today',
              ),
              style: AppTextStyles.label.copyWith(color: isDark ? Colors.grey.shade400 : AppColors.textMuted),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(insights.length, (index) {
                final text = insights[index];
                final isLast = index == insights.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0.0 : AppSpacing.p12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.p4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF8E75C8) : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          text,
                          style: AppTextStyles.caption.copyWith(color: isDark ? Colors.grey.shade300 : AppColors.loginSubTitle,
                            height: 1.4),
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
