import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/login/widgets/signup_form.dart';
import 'package:expense_tracker/features/login/widgets/signup_header.dart';
import 'package:expense_tracker/features/login/widgets/signup_login_link.dart';
import 'package:expense_tracker/features/login/widgets/signup_social_buttons.dart';
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
                            onLoginTap: () => Navigator.pop(context),
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