import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? textColor;
  final Widget? leading;
  final Widget? trailing;
  final bool showBorder;
  final Color? borderColor;
  final String? fontFamily;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF0C4E3C),
    this.textColor,
    this.leading,
    this.trailing,
    this.showBorder = false,
    this.borderColor,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.h50,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.br12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: showBorder
                  ? borderColor ?? AppColors.loginLabelPasswordColor
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.br12),
          ),

          child: (leading == null && trailing == null)
              ? Center(
                  child: Text(
                    text,
                    style: AppTextStyles.partySubmitButtonText.copyWith(
                      color: textColor ?? Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: FittedBox(fit: BoxFit.contain, child: leading!),
                      ),

                    if (leading != null) const SizedBox(width: 12),

                    SizedBox(
                      width: 220,
                      child: Text(
                        text,
                        textAlign: TextAlign.left,
                        style: AppTextStyles.partySubmitButtonText.copyWith(
                          color: textColor ?? Colors.white,
                        ),
                      ),
                    ),

                    if (trailing != null) const SizedBox(width: 12),
                    if (trailing != null)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: FittedBox(fit: BoxFit.contain, child: trailing!),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
