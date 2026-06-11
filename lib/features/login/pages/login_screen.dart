import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/login/pages/forgot_password_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_text_field_widget.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    spacing: AppSpacing.s16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(AppImages.splashLogo, height: 64, width: 64),

                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginTitle,
                      ),

                      Text(
                        'Sign in to continue your financial journey',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginSubTitle,
                      ),

                      const CustomTextFieldWidget(
                        label: 'Email Address',
                        hintText: 'you@example.com',
                      ),

                      CustomTextFieldWidget(
                        label: 'Password',
                        hintText: '••••••••',
                        obscureText: true,
                        trailingLabelWidget: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.textFieldLabelPassword,
                          ),
                        ),
                      ),

                      CustomButton(
                        text: 'Sign In',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavScreen(),
                            ),
                          );
                        },
                      ),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: AppColors.dividerColor,
                              thickness: 2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.p16,
                            ),
                            child: const Text(
                              'or',
                              style: TextStyle(color: AppColors.dividerOrColor),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: AppColors.dividerColor,
                              thickness: 2,
                            ),
                          ),
                        ],
                      ),
                      CustomButton(
                        leading: Image.asset(AppImages.googleLogo),
                        showBorder: true,
                        borderColor: AppColors.borderColor,
                        text: 'Continue with Google',
                        textColor: AppColors.googleTextColor,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        onPressed: () {},
                        backgroundColor: AppColors.white,
                      ),

                      CustomButton(
                        leading: Image.asset(AppImages.facebookLogo),
                        showBorder: true,
                        borderColor: AppColors.borderColor,
                        text: 'Continue with Facebook',
                        textColor: AppColors.black,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        onPressed: () {},
                        backgroundColor: AppColors.white,
                      ),
                      CustomButton(
                        leading: Transform.scale(
                          scale: 1.4,
                          child: Image.asset(AppImages.appleLogo),
                        ),

                        showBorder: true,
                        borderColor: AppColors.borderColor,
                        text: 'Continue with Apple',
                        textColor: AppColors.googleTextColor,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        onPressed: () {},
                        backgroundColor: AppColors.white,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.accountText,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccountScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.signUpText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
