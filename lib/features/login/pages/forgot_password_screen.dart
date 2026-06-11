import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/pages/forgot_password_otp_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            spacing: AppSpacing.s16,

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                AppImages.forgetPassLogo,
                height: 380,
                width: double.infinity,
                fit: BoxFit.contain,
              ),

              Text(
                'Forgot password?',
                textAlign: TextAlign.center,
                style: AppTextStyles.loginTitle,
              ),

              Text(
                'No worries, it happens! Just enter your email address associated with your account.',
                textAlign: TextAlign.center,
                style: AppTextStyles.loginSubTitle,
              ),

              const SizedBox(height: 8),

              const CustomTextFieldWidget(
                label: 'Email Address',
                hintText: 'Enter your email',
              ),

              CustomButton(text: 'Send Code', onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordOtpScreen()));
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Remember password? ", style: AppTextStyles.accountText),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('Log in', style: AppTextStyles.signUpText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
