import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_round_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

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
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginTitle,
                      ),

                      Text(
                        'Join us to manage your finances smarter.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginSubTitle,
                      ),

                      const CustomTextFieldWidget(
                        label: 'Full Name',
                        hintText: 'John Doe',
                      ),

                      CustomTextFieldWidget(
                        label: 'Email Address',
                        hintText: 'john@example.com',
                      ),

                      CustomTextFieldWidget(
                        label: 'Password',
                        hintText: '••••••••',
                        obscureText: true,
                      ),
                      CustomTextFieldWidget(
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      CustomButton(text: 'Sign Up', onPressed: () {}),
                      SizedBox(height: 8),

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
                              'Or sign up with',
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomRoundButton(
                            imagePath: AppImages.googleLogo,
                            onPressed: () {},
                          ),

                          const SizedBox(width: 24),

                          CustomRoundButton(
                            imagePath: AppImages.appleLogo,
                            iconSize: 26,
                            onPressed: () {},
                          ),

                          const SizedBox(width: 24),

                          CustomRoundButton(
                            imagePath: AppImages.facebookLogo,
                            onPressed: () {},
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: AppTextStyles.accountText,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Log In',
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
