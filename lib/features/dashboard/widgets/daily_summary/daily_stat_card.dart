import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';

class DailyStatCard extends StatelessWidget {
  final String title;
  final String? value;
  final double? amount;
  final String subtitle;
  final IconData icon;
  final List<Color>? gradientColors;

  const DailyStatCard({
    super.key,
    required this.title,
    this.value,
    this.amount,
    required this.subtitle,
    required this.icon,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseGradient = gradientColors ?? (isDark
        ? [const Color(0xFF2E323E), const Color(0xFF22262E)]
        : [Colors.white, Colors.white]);

    final borderThemeColor = isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB);

    final valueStyle = TextStyle(
      fontSize: AppFontSizes.size20,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: baseGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSizes.size11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                if (amount != null)
                  PrivacyMaskedText(
                    amount: amount!,
                    style: valueStyle,
                  )
                else
                  Text(
                    value ?? '',
                    style: valueStyle,
                  ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppFontSizes.size9,
                    color: isDark ? Colors.grey.shade500 : AppColors.loginSubTitle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF8E75C8) : theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
