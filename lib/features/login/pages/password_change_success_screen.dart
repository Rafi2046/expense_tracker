import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class PasswordChangeSuccessScreen extends StatelessWidget {
  final String? email;

  const PasswordChangeSuccessScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
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
                  context.translate('reset_link_sent_title'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.loginTitle.copyWith(
                    color: theme.colorScheme.onSurface),
                ),
  
                Text(
                  context.translate('reset_link_sent_subtitle'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.loginSubTitle.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),

                const SizedBox(height: AppSpacing.s16),

                CustomButton(
                  text: context.translate('back_to_login'),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),

                if (email != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  GestureDetector(
                    onTap: () => _resendEmail(context),
                    child: Text(
                      context.translate('resend_email_link'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.activeGreen,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resendEmail(BuildContext context) async {
    if (email == null) return;
    try {
      await AuthService().sendPasswordResetEmail(email!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('password_reset_email_sent'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF6A53A1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
