import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TransactionPeriodSelector extends StatelessWidget {
  final TransactionPeriod selectedPeriod;
  final bool isDark;
  final ValueChanged<TransactionPeriod> onPeriodChanged;
  final VoidCallback? onFilterTap;

  const TransactionPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.isDark,
    required this.onPeriodChanged,
    this.onFilterTap,
  });

  Widget _buildSegment(String label, TransactionPeriod period) {
    final isSelected = selectedPeriod == period;
    final accentColor = const Color(0xFF6A53A1);

    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.r12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.p4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Row(
              children: [
                _buildSegment('Daily', TransactionPeriod.daily),
                const SizedBox(width: AppSpacing.s4),
                _buildSegment('Monthly', TransactionPeriod.monthly),
                const SizedBox(width: AppSpacing.s4),
                _buildSegment('Yearly', TransactionPeriod.yearly),
              ],
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: AppSpacing.s8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F1F3),
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
              child: Icon(
                LucideIcons.slidersHorizontal,
                size: 18,
                color: isDark ? Colors.white70 : const Color(0xFF31394D),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
