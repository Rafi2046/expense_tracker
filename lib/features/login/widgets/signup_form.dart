import 'package:flutter/material.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onSignUp;

  const SignupForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFieldWidget(
          controller: nameController,
          label: context.translate('full_name'),
          hintText: context.translate('full_name_hint'),
        ),
        CustomTextFieldWidget(
          controller: emailController,
          label: context.translate('email_address'),
          hintText: context.translate('email_hint'),
        ),
        CustomTextFieldWidget(
          controller: passwordController,
          label: context.translate('password'),
          hintText: '••••••••',
          obscureText: true,
        ),
        CustomTextFieldWidget(
          controller: confirmPasswordController,
          label: context.translate('confirm_password'),
          hintText: '••••••••',
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: isLoading ? context.translate('creating_account') : context.translate('sign_up'),
          onPressed: isLoading ? () {} : onSignUp,
        ),
      ],
    );
  }
}
