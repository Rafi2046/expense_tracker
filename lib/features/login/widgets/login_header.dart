import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class LoginHeader extends StatelessWidget {
  final bool biometricMode;
  final bool isDark;

  const LoginHeader({
    super.key,
    required this.biometricMode,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.splashLogo, height: 68, width: 68),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTextStyles.loginTitle.copyWith(
            fontSize: AppFontSizes.size28,
            color: isDark ? Colors.white : null,
          ),
        ),
        Text(
          biometricMode
              ? 'Authenticate to continue your financial journey'
              : 'Sign in to continue your financial journey',
          textAlign: TextAlign.center,
          style: AppTextStyles.loginSubTitle.copyWith(
            color: isDark ? Colors.grey.shade400 : null,
          ),
        ),
      ],
    );
  }
}
