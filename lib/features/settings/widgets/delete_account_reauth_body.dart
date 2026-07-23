import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DeleteAccountReauthBody extends StatelessWidget {
  final bool isPasswordUser;
  final bool isAppleUser;
  final bool isGoogleUser;
  final bool isDeleting;
  final TextEditingController passwordController;
  final VoidCallback onReauthenticate;

  const DeleteAccountReauthBody({
    super.key,
    required this.isPasswordUser,
    required this.isAppleUser,
    required this.isGoogleUser,
    required this.isDeleting,
    required this.passwordController,
    required this.onReauthenticate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : AppColors.dividerColor;

    return Column(
      children: [
        Text(
          context.translate('verify_identity_delete'),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
            height: 1.5),
        ),
        const SizedBox(height: AppSpacing.s16),
        if (isGoogleUser || isAppleUser) ...[
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isDeleting
                  ? context.translate('deleting')
                  : context.translate(isAppleUser ? 'continue_with_apple' : 'continue_with_google'),
              onPressed: !isDeleting ? onReauthenticate : () {},
              backgroundColor: isDark ? Colors.grey.shade700 : Colors.white,
              textColor: isDark ? Colors.white : Colors.black87,
              showBorder: true,
              borderColor: isDark ? Colors.grey.shade600 : borderColor,
            ),
          ),
        ] else if (isPasswordUser) ...[
          TextField(
            controller: passwordController,
            obscureText: true,
            textAlign: TextAlign.center,
            autofocus: true,
            style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: context.translate('enter_password'),
              hintStyle: AppTextStyles.body.copyWith(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.r12),
                borderSide: BorderSide(color: AppColors.activeRed, width: 2),
              ),
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              filled: true,
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isDeleting ? context.translate('deleting') : context.translate('reauthenticate_delete'),
              onPressed: !isDeleting ? onReauthenticate : () {},
              backgroundColor: AppColors.activeRed,
              textColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}
