import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  /// Supports sync or async handlers. Returning a [Future] triggers the
  /// animated loading wrap from `easy_loading_button`.
  final Function? onPressed;
  final Color backgroundColor;
  final Color? textColor;
  final Widget? leading;
  final Widget? trailing;
  final bool showBorder;
  final Color? borderColor;
  final String? fontFamily;
  /// When false, skips the EasyButton width animation (static tap only).
  final bool useLoadingAnimation;

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
    this.useLoadingAnimation = true,
  });

  bool get _useEasyButton =>
      useLoadingAnimation &&
      leading == null &&
      trailing == null &&
      !showBorder;

  @override
  Widget build(BuildContext context) {
    if (_useEasyButton) {
      return EasyButton(
        type: showBorder ? EasyButtonType.outlined : EasyButtonType.elevated,
        idleStateWidget: Text(
          text,
          style: AppTextStyles.partySubmitButtonText.copyWith(
            color: showBorder
                ? (textColor ?? backgroundColor)
                : (textColor ?? Colors.white),
            fontFamily: fontFamily,
          ),
        ),
        loadingStateWidget: CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            showBorder
                ? (textColor ?? backgroundColor)
                : (textColor ?? Colors.white),
          ),
        ),
        useWidthAnimation: true,
        useEqualLoadingStateWidgetDimension: true,
        width: double.infinity,
        height: AppSpacing.authFieldHeight,
        borderRadius: AppSpacing.authFieldBorderRadius,
        elevation: 0,
        contentGap: 6.0,
        buttonColor: showBorder
            ? (borderColor ?? AppColors.loginLabelPasswordColor)
            : backgroundColor,
        onPressed: onPressed,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.authFieldHeight,
      child: InkWell(
        onTap: onPressed == null ? null : () => onPressed!(),
        borderRadius: BorderRadius.circular(AppSpacing.authFieldBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: showBorder
                  ? borderColor ?? AppColors.loginLabelPasswordColor
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.authFieldBorderRadius),
          ),
          child: (leading == null && trailing == null)
              ? Center(
                  child: Text(
                    text,
                    style: AppTextStyles.partySubmitButtonText.copyWith(
                      color: textColor ?? Colors.white,
                      fontFamily: fontFamily,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null)
                      SizedBox(width: AppSpacing.s24,
                        height: 24,
                        child: FittedBox(fit: BoxFit.contain, child: leading!),
                      ),
                    if (leading != null) const SizedBox(width: AppSpacing.s12),
                    SizedBox(
                      width: 220,
                      child: Text(
                        text,
                        textAlign: TextAlign.left,
                        style: AppTextStyles.partySubmitButtonText.copyWith(
                          color: textColor ?? Colors.white,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                    if (trailing != null) const SizedBox(width: AppSpacing.s12),
                    if (trailing != null)
                      SizedBox(width: AppSpacing.s24,
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
