import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

Color _sectionBg(ThemeData theme) => theme.brightness == Brightness.dark
    ? Colors.white.withValues(alpha: 0.05)
    : const Color(0xFFF8F9FA);

class ExpenseHeroSection extends StatelessWidget {
  final ThemeData theme;
  final String sym;
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final TextEditingController titleController;
  final VoidCallback onChanged;

  const ExpenseHeroSection({
    super.key,
    required this.theme,
    required this.sym,
    required this.amountController,
    required this.amountFocusNode,
    required this.titleController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.activeGreen.withValues(alpha: 0.06),
            AppColors.activeGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.activeGreen.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sym,
                style: AppTextStyles.displayLarge.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.activeGreen.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 4),
              IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 60,
                    maxWidth: 200,
                  ),
                  child: TextField(
                    controller: amountController,
                    focusNode: amountFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    textAlign: TextAlign.center,
                    onChanged: (_) => onChanged(),
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: AppFontSizes.size36,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                    autofocus: true,
                    cursorColor: AppColors.activeGreen,
                    cursorWidth: 3,
                    cursorHeight: 44,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: AppTextStyles.displayLarge.copyWith(
                        fontSize: AppFontSizes.size36,
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.15,
                        ),
                      ),
                      border: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    scrollPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p14,
              vertical: AppSpacing.p12,
            ),
            decoration: BoxDecoration(
              color: _sectionBg(theme),
              borderRadius: BorderRadius.circular(AppSpacing.r10),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: titleController,
              textAlign: TextAlign.start,
              onChanged: (_) => onChanged(),
              style: AppTextStyles.bodyBold.copyWith(
                fontSize: AppFontSizes.size15,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.translate('expense_title_hint'),
                hintStyle: AppTextStyles.bodyBold.copyWith(
                  fontSize: AppFontSizes.size15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
