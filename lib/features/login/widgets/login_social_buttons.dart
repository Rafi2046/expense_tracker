import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';

class LoginSocialButtons extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback? onAppleSignIn;
  final VoidCallback onSignUp;

  const LoginSocialButtons({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.onGoogleSignIn,
    this.onAppleSignIn,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark ? Colors.grey.shade700 : AppColors.dividerColor,
                thickness: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p16,
              ),
              child: Text(
                'or',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : AppColors.dividerOrColor,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark ? Colors.grey.shade700 : AppColors.dividerColor,
                thickness: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        CustomButton(
          leading: Image.asset(AppImages.googleLogo),
          showBorder: true,
          borderColor: isDark ? Colors.grey.shade600 : AppColors.borderColor,
          text: 'Continue with Google',
          textColor: isDark ? Colors.white : AppColors.googleTextColor,
          fontFamily: GoogleFonts.inter().fontFamily,
          onPressed: isLoading ? () {} : onGoogleSignIn,
          backgroundColor: isDark ? Colors.grey.shade800 : AppColors.white,
        ),
        if (Platform.isIOS || Platform.isMacOS)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CustomButton(
              leading: Transform.scale(
                scale: 1.4,
                child: Image.asset(AppImages.appleLogo),
              ),
              showBorder: true,
              borderColor: isDark ? Colors.grey.shade600 : AppColors.borderColor,
              text: 'Continue with Apple',
              textColor: isDark ? Colors.white : AppColors.googleTextColor,
              fontFamily: GoogleFonts.inter().fontFamily,
              onPressed: isLoading ? () {} : onAppleSignIn!,
              backgroundColor: isDark ? Colors.grey.shade800 : AppColors.white,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: AppTextStyles.accountText.copyWith(
                color: isDark ? Colors.grey.shade400 : null,
              ),
            ),
            GestureDetector(
              onTap: onSignUp,
              child: Text(
                'Sign Up',
                style: AppTextStyles.signUpText.copyWith(
                  color: isDark ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
