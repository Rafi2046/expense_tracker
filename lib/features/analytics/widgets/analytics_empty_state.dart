import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Compact empty placeholder used inside analytics cards.
class AnalyticsEmptyState extends StatelessWidget {
  final String? titleKey;

  const AnalyticsEmptyState({
    super.key,
    this.titleKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p16,
        vertical: AppSpacing.p32,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.chartPie,
            size: 40,
            color: onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            context.translate(titleKey ?? 'no_analytics_data'),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
