import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class PasswordChangeSuccessScreen extends StatelessWidget {
  const PasswordChangeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            spacing: AppSpacing.s16,

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
            AppImages.tick,
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
              ),

              Text(
                'Reset Link Sent!',
                textAlign: TextAlign.center,
                style: AppTextStyles.loginTitle,
              ),

              Text(
                'We have sent a password reset link to your email. Please click the link in your inbox to set your new password, then return here to log in.',
                textAlign: TextAlign.center,
                style: AppTextStyles.loginSubTitle,
              ),

              const SizedBox(height: 20),

              CustomButton(
                text: 'Back to Login',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
