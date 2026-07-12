import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/features/login/widgets/custom_round_button.dart';

class SignupSocialButtons extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onGoogleSignUp;
  final VoidCallback? onAppleSignUp;

  const SignupSocialButtons({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.onGoogleSignUp,
    this.onAppleSignUp,
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: Text(
                'Or sign up with',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRoundButton(
              imagePath: AppImages.googleLogo,
              onPressed: isLoading ? () {} : onGoogleSignUp,
            ),
            if (Platform.isIOS || Platform.isMacOS) ...[
              const SizedBox(width: 24),
              CustomRoundButton(
                imagePath: AppImages.appleLogo,
                iconSize: 26,
                onPressed: isLoading ? () {} : onAppleSignUp!,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
