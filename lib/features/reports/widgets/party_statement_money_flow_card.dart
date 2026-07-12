import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartyStatementMoneyFlowCard extends StatelessWidget {
  final bool isInflow;
  final double amount;
  final bool isMasked;
  final bool isDark;

  const PartyStatementMoneyFlowCard({
    super.key,
    required this.isInflow,
    required this.amount,
    required this.isMasked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isInflow ? AppColors.activeGreen : AppColors.activeRed;
    final label = isInflow ? 'Money In' : 'Money Out';
    final icon = isInflow ? LucideIcons.arrowDown : LucideIcons.arrowUp;
    final bgColor = isDark
        ? color.withValues(alpha: 0.08)
        : (isInflow ? const Color(0xFFF2FBF7) : const Color(0xFFFFF5F5));
    final borderColor = isDark
        ? color.withValues(alpha: 0.2)
        : (isInflow ? const Color(0xFFD8F3E5) : const Color(0xFFFAD1D1));
    final iconBgColor = isDark
        ? color.withValues(alpha: 0.15)
        : (isInflow ? const Color(0xFFE1F7EC) : const Color(0xFFFFEAEA));
    final labelColor = (isDark ? color : (isInflow ? const Color(0xFF146C48) : const Color(0xFFDC3545))).withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                PrivacyMaskedText(
                  amount: amount,
                  isMasked: isMasked,
                  style: AppTextStyles.reportTransactionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
