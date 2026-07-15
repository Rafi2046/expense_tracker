import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class GlobalBalancePreview extends StatelessWidget {
  const GlobalBalancePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.wallet,
                    size: 16, color: AppColors.activeGreen),
                const SizedBox(width: 8),
                Text(
                  context.translate('across_all_tours'),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BalanceTile(
                    label: context.translate('you_owe_amount'),
                    amount: '\$340.00',
                    isNegative: true,
                    labelColor: labelColor,
                  ),
                ),
                Container(width: 1, height: 40,
                    color: borderColor),
                Expanded(
                  child: _BalanceTile(
                    label: context.translate('you_are_owed_amount'),
                    amount: '\$890.50',
                    isNegative: false,
                    labelColor: labelColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String label;
  final String amount;
  final bool isNegative;
  final Color labelColor;

  const _BalanceTile({
    required this.label,
    required this.amount,
    required this.isNegative,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: labelColor,
            ),
          ),
        const SizedBox(height: 6),
          Text(
            amount,
            style: isNegative ? AppTextStyles.cardValueRed : AppTextStyles.cardValueGreen,
          ),
      ],
    );
  }
}
