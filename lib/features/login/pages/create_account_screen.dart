import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/app_lock_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/email_validator.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/login/pages/verify_email_screen.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/widgets/signup_form.dart';
import 'package:expense_tracker/features/login/widgets/signup_header.dart';
import 'package:expense_tracker/features/login/widgets/signup_login_link.dart';
import 'package:expense_tracker/features/login/widgets/signup_social_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



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

  String _emailErrorMessage(EmailValidationFailure? failure) {
    switch (failure) {
      case EmailValidationFailure.empty:
        return context.translate('please_enter_email');
      case EmailValidationFailure.disposable:
        return context.translate('email_disposable_not_allowed');
      case EmailValidationFailure.notReal:
        return context.translate('please_enter_real_email');
      case EmailValidationFailure.noMx:
        return context.translate('email_domain_invalid');
      case EmailValidationFailure.badFormat:
      case null:
        return context.translate('please_enter_valid_email');
    }
  }

  // 3. Handle Email/Password Sign Up
  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation — stay on this screen for any failure
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar(context.translate('please_fill_fields'));
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar(context.translate('passwords_do_not_match'));
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar(context.translate('password_min_length'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Deep email check (format + fake/gibberish + disposable + MX)
      final emailResult = await EmailValidator.validate(email);
      if (!emailResult.isValid) {
        if (mounted) {
          _showErrorSnackBar(_emailErrorMessage(emailResult.failure));
        }
        return;
      }

      // Create user only after email passes validation
      final userCredential = await _authService.signUpWithEmail(email, password);

      // Update Firebase Profile with the user's Full Name
      if (userCredential != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);

        if (mounted) {
          // Navigate to Verify Email Screen only after successful signup
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const VerifyEmailScreen(isFromSignup: true)),
                (route) => false,
          );
        }
      }
    } catch (e) {
      // Firebase invalid-email / other auth errors — stay here, show alert
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. Handle Google Sign Up (Same logic as Login)
  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    try {
      if (mounted) {
        context.read<AppLockProvider>().suppressNextLock();
      }
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            (route) => false,
          );
        });
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
      if (mounted) {
        context.read<AppLockProvider>().suppressNextLock();
      }
      final userCredential = await _authService.signInWithApple();

      if (userCredential != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
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

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _navigateToLogin();
      },
      child: Scaffold(
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
                    horizontal: AppSpacing.p24,
                    vertical: AppSpacing.p40,
                  ),
                  child: Column(
                    spacing: AppSpacing.s16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SignupHeader(isDark: isDark),
                      SignupForm(
                        nameController: _nameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        isLoading: _isLoading,
                        onSignUp: _handleSignUp,
                      ),
                      Column(
                        spacing: AppSpacing.s8,
                        children: [
                          SignupSocialButtons(
                            isDark: isDark,
                            isLoading: _isLoading,
                            onGoogleSignUp: _handleGoogleSignUp,
                            onAppleSignUp: _handleAppleSignUp,
                          ),
                          SignupLoginLink(
                            isDark: isDark,
                            onLoginTap: _navigateToLogin,
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
    ),
    );
  }
}