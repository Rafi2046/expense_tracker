import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
          context.translate('already_have_account'),
          style: AppTextStyles.accountText.copyWith(
            color: isDark ? Colors.grey.shade400 : null,
          ),
        ),
        GestureDetector(
          onTap: onLoginTap,
          child: Text(
            context.translate('log_in_capital'),
            style: AppTextStyles.signUpText.copyWith(
              color: isDark ? Colors.white : null,
            ),
          ),
        ),
      ],
    );
  }
}
