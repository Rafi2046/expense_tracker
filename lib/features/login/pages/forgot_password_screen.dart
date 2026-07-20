import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/pages/password_change_success_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_enter_email')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_enter_valid_email')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('password_reset_email_sent'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF6A53A1),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordChangeSuccessScreen(email: email),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  AppImages.forgetPassLogo,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),

                Column(
                  spacing: AppSpacing.s4,
                  children: [
                    Text(
                      context.translate('forgot_password_title'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.loginTitle.copyWith(
                        fontSize: AppFontSizes.size28,
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    Text(
                      context.translate('forgot_password_subtitle'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.loginSubTitle.copyWith(
                        color: isDark ? Colors.grey.shade400 : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),

                CustomTextFieldWidget(
                  label: context.translate('email_address'),
                  hintText: context.translate('enter_your_email'),
                  controller: _emailController,
                ),
                const SizedBox(height: AppSpacing.s16),
                CustomButton(
                  text: _isLoading ? context.translate('sending') : context.translate('send_link'),
                  onPressed: _isLoading ? () {} : _sendResetEmail,
                ),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.translate('remember_password'),
                      style: AppTextStyles.accountText.copyWith(
                        color: isDark ? Colors.grey.shade400 : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        context.translate('log_in'),
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
      ),
    );
  }
}
