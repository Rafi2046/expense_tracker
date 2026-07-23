import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class ExpenseBreakdownItem {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  ExpenseBreakdownItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.iconColor = AppColors.activeGreen,
    this.iconBgColor = const Color(0xFFE8F8F5),
  });
}

class ExpenseBreakdownCard extends StatelessWidget {
  final String suffixText;
  final List<ExpenseBreakdownItem> items;
  final bool isMasked;

  const ExpenseBreakdownCard({
    super.key,
    required this.suffixText,
    required this.items,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(
          color: (theme.dividerTheme.color ?? AppColors.dividerColor).withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          RichText(
            text: TextSpan(
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: TextStyle().fontFamily,
              ),
              children: [
                TextSpan(text: '${context.translate('expense_breakdown')} '),
                TextSpan(
                  text: suffixText,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w400,
                    color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Items list
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final item = items[index];
              final rawAmount = double.tryParse(item.amount) ?? 0.0;
              return Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? (item.iconBgColor == const Color(0xFFE8F8F5)
                              ? AppColors.activeGreen.withValues(alpha: 0.15)
                              : item.iconBgColor.withValues(alpha: 0.2))
                          : item.iconBgColor,
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.s16),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (() {
                            final lowerTitle = item.title.toLowerCase();
                            return (lowerTitle == 'cash' || lowerTitle == 'bank') 
                                ? context.translate(lowerTitle) 
                                : item.title;
                          })(),
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontFamily: TextStyle().fontFamily,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          (() {
                            final subtitle = item.subtitle;
                            if (subtitle.contains('transactions')) {
                              final countStr = subtitle.split(' ').first;
                              final count = int.tryParse(countStr) ?? 0;
                              return count == 1
                                  ? context.translate('transaction_count_singular')
                                  : context.translate('transaction_count_plural').replaceAll('{count}', '$count');
                            }
                            return subtitle;
                          })(),
                          style: AppTextStyles.label.copyWith(color: AppColors.textMuted,
                            fontFamily: TextStyle().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  PrivacyMaskedText(
                    amount: rawAmount,
                    isMasked: isMasked,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
