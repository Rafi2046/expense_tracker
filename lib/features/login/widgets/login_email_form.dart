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
    final theme = Theme.of(context);
    final showForgotPassword = !biometricMode && onForgotPassword != null;

    return Column(
      spacing: AppSpacing.authFieldGroupGap,
      children: [
        CustomTextFieldWidget(
          controller: emailController,
          label: context.translate('email_address'),
          hintText: context.translate('email_hint'),
          keyboardType: TextInputType.emailAddress,
        ),
        if (!biometricMode || hasPasswordProvider)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFieldWidget(
                controller: passwordController,
                label: context.translate('password'),
                hintText: '••••••••',
                obscureText: true,
              ),
              if (showForgotPassword)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(top: AppSpacing.s4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: isDark
                          ? Colors.grey.shade300
                          : AppTextStyles.textFieldLabelPassword.color,
                    ),
                    child: Text(
                      context.translate('forgot_password_link'),
                      style: AppTextStyles.textFieldLabelPassword.copyWith(
                        color: isDark
                            ? Colors.grey.shade300
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
