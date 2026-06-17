import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/login/pages/forgot_password_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_field_widget.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

                      CustomTextFieldWidget(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'you@example.com',
                      ),

                      CustomTextFieldWidget(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: '••••••••',
                        obscureText: true,
                        trailingLabelWidget: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
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
                        text: _isLoading ? 'Signing In...' : 'Sign In',
                        onPressed: _isLoading ? () {} : _handleEmailLogin,
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
                            padding: const EdgeInsets.symmetric(
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

                      // Google Login Button
                      CustomButton(
                        leading: Image.asset(AppImages.googleLogo),
                        showBorder: true,
                        borderColor: AppColors.borderColor,
                        text: 'Continue with Google',
                        textColor: AppColors.googleTextColor,
                        fontFamily: GoogleFonts.inter().fontFamily,
                        onPressed: _isLoading ? () {} : _handleGoogleLogin,
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

                      const SizedBox(height: 8),
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
                                  builder: (context) =>
                                      const CreateAccountScreen(),
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
