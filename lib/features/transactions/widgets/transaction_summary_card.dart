import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TransactionSummaryCard extends StatelessWidget {
  final bool isMasked;
  final VoidCallback onToggleMask;

  const TransactionSummaryCard({
    super.key,
    required this.isMasked,
    required this.onToggleMask,
  });

  String _formatPeriodLabel(TransactionProvider provider) {
    final date = provider.selectedDate;
    final period = provider.selectedPeriod;
    if (period == TransactionPeriod.daily) {
      return DateFormat('dd MMM yyyy').format(date);
    } else if (period == TransactionPeriod.yearly) {
      return DateFormat('yyyy').format(date);
    } else {
      return DateFormat('MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final totalIncome = provider.periodIncome;
    final totalExpense = provider.periodExpense;
    final netBalance = provider.periodNetBalance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF32235B), Color(0xFF6A53A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A53A1).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.translate('net_balance').toUpperCase(),
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.r24),
                ),
                child: Text(
                  _formatPeriodLabel(provider),
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onToggleMask();
                },
                child: Icon(
                  isMasked ? LucideIcons.shield : LucideIcons.shieldOff,
                  size: 20,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),

          // Net Balance Value
          PrivacyMaskedText(
            amount: netBalance,
            isMasked: isMasked,
            style: AppTextStyles.reportLargeValue.copyWith(
              color: Colors.white,
              letterSpacing: -0.5),
          ),
          const SizedBox(height: AppSpacing.s8),

          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: AppSpacing.s8),

          // Income vs Expense row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.arrowDown,
                        color: Color(0xFF2ECC71),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('income'),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          PrivacyMaskedText(
                            amount: totalIncome,
                            isMasked: isMasked,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: AppSpacing.s12),

              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.arrowUp,
                        color: Color(0xFFF1948A),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('expense'),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          PrivacyMaskedText(
                            amount: totalExpense,
                            isMasked: isMasked,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
