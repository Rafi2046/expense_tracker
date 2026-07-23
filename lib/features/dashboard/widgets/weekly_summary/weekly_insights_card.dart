import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class WeeklyInsightsCard extends StatelessWidget {
  final List<String> insights;
  final Color activeColor;
  final bool isDark;

  const WeeklyInsightsCard({
    super.key,
    required this.insights,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.lightbulb, color: activeColor, size: 20),
            const SizedBox(width: AppSpacing.s8),
            Text(
              context.translate('weekly_insights'),
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.p16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.r24),
            border: Border.all(
              color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
            ),
          ),
          child: insights.isEmpty
              ? Text(
                  context.translate('no_insights'),
                  style: AppTextStyles.label.copyWith(color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: insights.map((insight) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.p12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: AppSpacing.p4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Text(
                              insight,
                              style: AppTextStyles.label.copyWith(color: isDark ? Colors.grey.shade300 : AppColors.loginSubTitle,
                                height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
