import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class SettleUpSummaryCard extends StatelessWidget {
  final String formattedAmount;

  const SettleUpSummaryCard({super.key, required this.formattedAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.p16,
        horizontal: AppSpacing.p24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.translate('total_outstanding_label'),
            style: AppTextStyles.cardTitle.copyWith(
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            formattedAmount,
            style: AppTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p12,
              vertical: AppSpacing.p4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.r24),
            ),
            child: Text(
              context.translate('outstanding_balances_settle'),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
