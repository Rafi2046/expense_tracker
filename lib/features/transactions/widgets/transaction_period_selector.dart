import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';

class TransactionPeriodSelector extends StatelessWidget {
  final TransactionPeriod selectedPeriod;
  final bool isDark;
  final ValueChanged<TransactionPeriod> onPeriodChanged;

  const TransactionPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.isDark,
    required this.onPeriodChanged,
  });

  Widget _buildSegment(String label, TransactionPeriod period) {
    final isSelected = selectedPeriod == period;
    final accentColor = const Color(0xFF6A53A1);

    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: AppFontSizes.size12,
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegment('Daily', TransactionPeriod.daily),
          const SizedBox(width: 4),
          _buildSegment('Monthly', TransactionPeriod.monthly),
          const SizedBox(width: 4),
          _buildSegment('Yearly', TransactionPeriod.yearly),
        ],
      ),
    );
  }
}
