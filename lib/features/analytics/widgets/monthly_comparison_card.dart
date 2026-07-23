import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final maxAmount = currentAmount > previousAmount ? currentAmount : previousAmount;
    final currentPct = maxAmount > 0 ? currentAmount / maxAmount : 0.0;
    final previousPct = maxAmount > 0 ? previousAmount / maxAmount : 0.0;

    final isUp = currentAmount >= previousAmount;
    final changeColor = isUp ? AppColors.activeRed : AppColors.activeGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE24361), Color(0xFFF59E0B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                context.translate('monthly_comparison'),
                style: AppTextStyles.h2.copyWith(color: onSurface),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          Row(
            children: [
              Expanded(
                child: _MonthCard(
                  label: context.translate('this_month'),
                  amount: currentAmount,
                  progress: currentPct,
                  color: const Color(0xFF2EBD85),
                  isMasked: isMasked,
                  isDark: isDark,
                  onSurface: onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _MonthCard(
                  label: context.translate('last_month'),
                  amount: previousAmount,
                  progress: previousPct,
                  color: isDark ? Colors.grey.shade600 : const Color(0xFFB3C5B9),
                  isMasked: isMasked,
                  isDark: isDark,
                  onSurface: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.p12),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.translate('net_change'),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
                ),
                Row(
                  children: [
                    Icon(
                      isUp ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                      color: changeColor,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      netChangeText,
                      style: AppTextStyles.bodyBold.copyWith(
                        fontWeight: FontWeight.w800,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final String label;
  final double amount;
  final double progress;
  final Color color;
  final bool isMasked;
  final bool isDark;
  final Color onSurface;

  const _MonthCard({
    required this.label,
    required this.amount,
    required this.progress,
    required this.color,
    required this.isMasked,
    required this.isDark,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE8EAED),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: PrivacyMaskedText(
              amount: amount,
              isMasked: isMasked,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE8EAED),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
