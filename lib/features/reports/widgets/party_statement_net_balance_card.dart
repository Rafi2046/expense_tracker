import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';

class PartyStatementNetBalanceCard extends StatelessWidget {
  final double netBalance;
  final bool isReceivable;
  final bool isMasked;
  final bool isDark;
  final String? label;

  const PartyStatementNetBalanceCard({
    super.key,
    required this.netBalance,
    required this.isReceivable,
    required this.isMasked,
    required this.isDark,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? (isReceivable ? 'Total Receivables' : 'Total Payables');
    final cardBgGradient = isReceivable
        ? (isDark
              ? LinearGradient(
                  colors: [
                    AppColors.activeGreen.withValues(alpha: 0.15),
                    AppColors.activeGreen.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFF4FBF9), Color(0xFFE8F7F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
        : (isDark
              ? LinearGradient(
                  colors: [
                    AppColors.activeRed.withValues(alpha: 0.15),
                    AppColors.activeRed.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFF7F7), Color(0xFFFDECEC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ));
    final cardBorderColor = isReceivable
        ? (isDark
              ? AppColors.activeGreen.withValues(alpha: 0.3)
              : const Color(0xFFD3EFE8))
        : (isDark
              ? AppColors.activeRed.withValues(alpha: 0.3)
              : const Color(0xFFFBD7D7));
    final cardAccentColor =
        isReceivable ? AppColors.activeGreen : AppColors.activeRed;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: cardBgGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: cardAccentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayLabel,
                        style: AppTextStyles.reportStatLabel.copyWith(
                          color: isReceivable
                              ? (isDark
                                        ? AppColors.activeGreen
                                        : const Color(0xFF146C48))
                                    .withValues(alpha: 0.7)
                              : (isDark
                                        ? AppColors.activeRed
                                        : const Color(0xFFDC3545))
                                    .withValues(alpha: 0.7),
                          fontSize: AppFontSizes.size12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PrivacyMaskedText(
                        amount: netBalance.abs(),
                        isMasked: isMasked,
                        style: AppTextStyles.reportLargeValue.copyWith(
                          color: cardAccentColor,
                          fontSize: AppFontSizes.size24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
