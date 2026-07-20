import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/pages/password_change_success_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

Color accentPurpleColor = const Color(0xFF6A53A1);
Color primaryColor = const Color(0xFF121212);
Color accentPinkColor = const Color(0xFFF99BBD);
Color accentDarkGreenColor = const Color(0xFF115C49);
Color accentYellowColor = const Color(0xFFFFB612);
Color accentOrangeColor = const Color(0xFFEA7A3B);

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  String _otpCode = '';

  void _verifyOtp() {
    if (_otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('otp_digit_warning')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Since Firebase uses the email link to reset the password, we simulate the OTP verification
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordChangeSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                spacing: AppSpacing.h20,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    AppImages.otpLogo,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),

                  Text(
                    context.translate('reset_verification_title'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.loginTitle,
                  ),
 
                  Text(
                    context.translate('otp_instruction'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.loginSubTitle,
                  ),
 
                  OtpTextField(
                    numberOfFields: 4,
                    borderColor: accentPurpleColor,
                    focusedBorderColor: accentDarkGreenColor,
                    showFieldAsBox: true,
                    mainAxisAlignment: MainAxisAlignment.center,
                    borderRadius: BorderRadius.circular(12),
                    borderWidth: 1.5,
                    fieldHeight: 55,
                    fieldWidth: 55,
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    onCodeChanged: (String code) {
                      _otpCode = code;
                    },
                    onSubmit: (String verificationCode) {
                      _otpCode = verificationCode;
                      _verifyOtp();
                    },
                  ),
 
                  CustomButton(
                    text: context.translate('verify'),
                    onPressed: _verifyOtp,
                  ),
 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.translate('did_not_receive_code'),
                        style: AppTextStyles.accountText,
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.translate('verification_link_resent'),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF6A53A1),
                            ),
                          );
                        },
                        child: Text(
                          context.translate('resend'),
                          style: AppTextStyles.signUpText.copyWith(
                            color: accentDarkGreenColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
