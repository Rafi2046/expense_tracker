import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/social_provider_buttons.dart';

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
        SocialProviderButtons(
          isDark: isDark,
          isLoading: isLoading,
          dividerText: context.translate('or'),
          onGoogle: onGoogleSignIn,
          onApple: onAppleSignIn,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.translate('dont_have_account'),
              style: AppTextStyles.accountText.copyWith(
                color: isDark ? Colors.grey.shade400 : null,
              ),
            ),
            GestureDetector(
              onTap: onSignUp,
              child: Text(
                context.translate('sign_up'),
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
