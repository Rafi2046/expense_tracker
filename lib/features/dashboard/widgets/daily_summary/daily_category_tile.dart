import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class DailyCategoryTile extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;

  const DailyCategoryTile({
    super.key,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.p12,
        vertical: AppSpacing.p8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22262E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Flexible(
                      child: Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      '(${(percentage * 100).toStringAsFixed(1)}%)',
                      style: AppTextStyles.caption.copyWith(color: isDark ? Colors.grey.shade500 : AppColors.textMuted,
                        fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              PrivacyMaskedText(
                amount: amount,
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.r8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark ? const Color(0xFF2E323E) : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
