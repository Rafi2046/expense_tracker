import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TransactionAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Color themeColor;
  final String currencySymbol;

  const TransactionAmountInput({
    super.key,
    required this.controller,
    required this.themeColor,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p24, horizontal: AppSpacing.p16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  themeColor.withValues(alpha: 0.08),
                  themeColor.withValues(alpha: 0.03),
                ]
              : [
                  themeColor.withValues(alpha: 0.04),
                  themeColor.withValues(alpha: 0.015),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        border: Border.all(
          color: themeColor.withValues(alpha: isDark ? 0.15 : 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // ── "Amount" floating label ──
          Text(
            context.translate('amount_label').toUpperCase(),
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700,
              color: themeColor.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),

          // ── The actual input ──
          Center(
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Currency prefix
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.p4),
                    child: Text(
                      currencySymbol,
                      style: AppTextStyles.displayLarge.copyWith(fontWeight: FontWeight.w700,
                        color: themeColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  // Amount field
                  IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 80, maxWidth: 220),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(fontWeight: FontWeight.w800,
                          color: themeColor,
                          letterSpacing: -1),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: AppTextStyles.displayLarge.copyWith(fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade200,
                            letterSpacing: -1,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
