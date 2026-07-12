import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartyStatementTableRow extends StatelessWidget {
  final String description;
  final DateTime dateTime;
  final double amount;
  final bool isInflow;
  final bool isMasked;
  final bool isDark;
  final VoidCallback? onTap;

  const PartyStatementTableRow({
    super.key,
    required this.description,
    required this.dateTime,
    required this.amount,
    required this.isInflow,
    required this.isMasked,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.05 : 0.005,
              ),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      description,
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        fontSize: AppFontSizes.size13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy • h:mm a').format(dateTime),
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        fontSize: AppFontSizes.size10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                child: isInflow
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.activeGreen.withValues(alpha: 0.15)
                              : const Color(0xFFE8F8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.activeGreen.withValues(alpha: 0.3)
                                : const Color(0xFFD1F2E5),
                          ),
                        ),
                        child: PrivacyMaskedText(
                          amount: amount,
                          isMasked: isMasked,
                          style: AppTextStyles.reportTransactionTitle.copyWith(
                            fontSize: AppFontSizes.size12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.activeGreen,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                child: !isInflow
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.activeRed.withValues(alpha: 0.15)
                              : const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.activeRed.withValues(alpha: 0.3)
                                : const Color(0xFFFAD1D1),
                          ),
                        ),
                        child: PrivacyMaskedText(
                          amount: amount,
                          isMasked: isMasked,
                          style: AppTextStyles.reportTransactionTitle.copyWith(
                            fontSize: AppFontSizes.size12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.activeRed,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
