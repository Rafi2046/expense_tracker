import 'package:flutter/material.dart';
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
          label: 'Full Name',
          hintText: 'John Doe',
        ),
        CustomTextFieldWidget(
          controller: emailController,
          label: 'Email Address',
          hintText: 'john@example.com',
        ),
        CustomTextFieldWidget(
          controller: passwordController,
          label: 'Password',
          hintText: '••••••••',
          obscureText: true,
        ),
        CustomTextFieldWidget(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          hintText: '••••••••',
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: isLoading ? 'Creating Account...' : 'Sign Up',
          onPressed: isLoading ? () {} : onSignUp,
        ),
      ],
    );
  }
}
