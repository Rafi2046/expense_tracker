import 'dart:io' show Platform;
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_round_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';



class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // 1. Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 2. AuthService instance and Loading State
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 3. Handle Email/Password Sign Up
  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters long');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user
      final userCredential = await _authService.signUpWithEmail(email, password);

      // Update Firebase Profile with the user's Full Name
      if (userCredential != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);

        if (mounted) {
          // Navigate to Dashboard and clear history
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. Handle Google Sign Up (Same logic as Login)
  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignUp() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithApple();

      if (userCredential != null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper method for errors
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
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
                        style: AppTextStyles.loginTitle.copyWith(
                          color: isDark ? Colors.white : null,
                        ),
                      ),

                      Text(
                        'Join us to manage your finances smarter.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginSubTitle.copyWith(
                          color: isDark ? Colors.grey.shade400 : null,
                        ),
                      ),

                      // Controllers attached here
                      CustomTextFieldWidget(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'John Doe',
                      ),

                      CustomTextFieldWidget(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'john@example.com',
                      ),

                      CustomTextFieldWidget(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: '••••••••',
                        obscureText: true,
                      ),

                      CustomTextFieldWidget(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        obscureText: true,
                      ),

                      const SizedBox(height: 16),

                      // Action mapped to button
                      CustomButton(
                        text: _isLoading ? 'Creating Account...' : 'Sign Up',
                        onPressed: _isLoading ? () {} : _handleSignUp,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.grey.shade700 : AppColors.dividerColor,
                              thickness: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.p16,
                            ),
                            child: Text(
                              'Or sign up with',
                              style: TextStyle(color: isDark ? Colors.grey.shade400 : AppColors.dividerOrColor),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark ? Colors.grey.shade700 : AppColors.dividerColor,
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
                            onPressed: _isLoading ? () {} : _handleGoogleSignUp,
                          ),

                          if (Platform.isIOS || Platform.isMacOS) ...[
                            const SizedBox(width: 24),
                            CustomRoundButton(
                              imagePath: AppImages.appleLogo,
                              iconSize: 26,
                              onPressed: _isLoading ? () {} : _handleAppleSignUp,
                            ),
                          ],
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: AppTextStyles.accountText.copyWith(
                              color: isDark ? Colors.grey.shade400 : null,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Changed from Navigator.push to Navigator.pop
                              // This prevents infinitely stacking login/signup screens
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Log In',
                              style: AppTextStyles.signUpText.copyWith(
                                color: isDark ? Colors.white : null,
                              ),
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