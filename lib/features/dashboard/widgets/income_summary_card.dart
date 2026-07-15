import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeSummaryCard extends StatelessWidget {
  final String label;
  final Widget amount;
  final String? percentageText;
  final String? compareText;
  final Widget? bottomContent;
  final bool showDivider;
  final bool isMasked;
  final VoidCallback onToggleMask;

  const IncomeSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    this.percentageText,
    this.compareText,
    this.bottomContent,
    this.showDivider = false,
    required this.isMasked,
    required this.onToggleMask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label.toUpperCase(), style: AppTextStyles.summaryCardLabel),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggleMask();
                },
                child: Icon(
                  isMasked ? LucideIcons.shield : LucideIcons.shieldOff,
                  size: 18,
                  color: isDark ? Colors.white38 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          amount,
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
                    color: isDark 
                        ? AppColors.activeGreen.withValues(alpha: 0.15) 
                        : AppColors.selectionGreenBg,
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
                    fontSize: AppFontSizes.size13,
                    color: isDark ? Colors.white70 : AppColors.loginSubTitle,
                    fontFamily: TextStyle().fontFamily,
                  ),
                ),
              ],
            ),
          ] else if (percentageText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  LucideIcons.trendingUp,
                  color: AppColors.activeGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  percentageText!,
                  style: TextStyle(
                    fontSize: AppFontSizes.size13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.activeGreen,
                    fontFamily: TextStyle().fontFamily,
                  ),
                ),
              ],
            ),
          ],
          if (showDivider) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: (theme.dividerTheme.color ?? AppColors.dividerColor).withValues(alpha: 0.5),
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
