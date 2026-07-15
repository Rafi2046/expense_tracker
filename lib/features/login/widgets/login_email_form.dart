import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';

class LoginEmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool biometricMode;
  final bool hasPasswordProvider;
  final bool isDark;
  final VoidCallback? onForgotPassword;

  const LoginEmailForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.biometricMode,
    required this.hasPasswordProvider,
    required this.isDark,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.s4,
      children: [
        CustomTextFieldWidget(
          controller: emailController,
          label: context.translate('email_address'),
          hintText: context.translate('email_hint'),
        ),
        if (!biometricMode || hasPasswordProvider)
          CustomTextFieldWidget(
            controller: passwordController,
            label: context.translate('password'),
            hintText: '••••••••',
            obscureText: true,
            trailingLabelWidget: biometricMode
                ? null
                : GestureDetector(
                    onTap: onForgotPassword,
                    child: Text(
                      context.translate('forgot_password_link'),
                      style: AppTextStyles.textFieldLabelPassword.copyWith(
                        color: isDark ? Colors.grey.shade400 : null,
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
