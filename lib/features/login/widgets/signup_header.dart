import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class SignupHeader extends StatelessWidget {
  final bool isDark;

  const SignupHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppImages.splashLogo, height: 70, width: 70),
        Text(
          'Create Account',
          textAlign: TextAlign.center,
          style: AppTextStyles.loginTitle.copyWith(
            fontSize: AppFontSizes.size28,
            color: isDark ? Colors.white : null,
          ),
        ),
        Text(
          'Join us to manage your finances smarter.',
          textAlign: TextAlign.center,
          style: AppTextStyles.loginSubTitle.copyWith(
            color: isDark ? Colors.grey.shade400 : null,
          ),
        ),
      ],
    );
  }
}
