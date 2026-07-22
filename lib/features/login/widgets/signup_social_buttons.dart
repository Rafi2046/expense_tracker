import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/social_provider_buttons.dart';

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
    return SocialProviderButtons(
      isDark: isDark,
      isLoading: isLoading,
      dividerText: context.translate('or_sign_up_with'),
      onGoogle: onGoogleSignUp,
      onApple: onAppleSignUp,
    );
  }
}
