import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class SignupLoginLink extends StatelessWidget {
  final bool isDark;
  final VoidCallback onLoginTap;

  const SignupLoginLink({
    super.key,
    required this.isDark,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: AppTextStyles.accountText.copyWith(
            color: isDark ? Colors.grey.shade400 : null,
          ),
        ),
        GestureDetector(
          onTap: onLoginTap,
          child: Text(
            'Log In',
            style: AppTextStyles.signUpText.copyWith(
              color: isDark ? Colors.white : null,
            ),
          ),
        ),
      ],
    );
  }
}
