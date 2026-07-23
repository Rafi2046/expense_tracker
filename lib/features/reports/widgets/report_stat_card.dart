import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class ReportStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isPositive;
  final bool isMasked;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.isPositive,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.reportStatLabel.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          GestureDetector(
            onTap: () {
              final formatted = context.formatAmount(amount, listen: false);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(title),
                  content: Text(
                    formatted,
                    style: AppTextStyles.reportStatValue.copyWith(
                      color: isPositive
                          ? theme.primaryColor
                          : AppColors.activeRed,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(context.translate('ok')),
                    ),
                  ],
                ),
              );
            },
            child: PrivacyMaskedText(
              amount: amount,
              isMasked: isMasked,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.reportStatValue.copyWith(
                color: isPositive ? theme.primaryColor : AppColors.activeRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
