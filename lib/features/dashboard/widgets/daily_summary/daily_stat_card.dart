import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class DailyStatCard extends StatelessWidget {
  final String title;
  final String? value;
  final double? amount;
  final String subtitle;
  final IconData? icon;
  final List<Color>? gradientColors;
  final List<Color>? iconGradient;

  const DailyStatCard({
    super.key,
    required this.title,
    this.value,
    this.amount,
    required this.subtitle,
    this.icon,
    this.gradientColors,
    this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseGradient = gradientColors ?? (isDark
        ? [const Color(0xFF2E323E), const Color(0xFF22262E)]
        : [Colors.white, Colors.white]);

    final borderThemeColor = isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB);

    final valueStyle = AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface);

    final defaultIconGradient = isDark
        ? [const Color(0xFF8E75C8), const Color(0xFF6B5BA7)]
        : [const Color(0xFF1B6B45), const Color(0xFF2EBD85)];

    final colors = iconGradient ?? defaultIconGradient;

    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: baseGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
          color: borderThemeColor,
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.s8),
                if (amount != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: PrivacyMaskedText(
                      amount: amount!,
                      style: valueStyle,
                    ),
                  )
                else
                  Text(
                    value ?? '',
                    style: valueStyle,
                  ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: isDark ? Colors.grey.shade500 : AppColors.loginSubTitle,
                    fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          if (icon != null)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.r12),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon!,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
