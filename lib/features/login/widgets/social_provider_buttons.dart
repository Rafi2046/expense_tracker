import 'dart:io' show Platform;

import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared Google / Apple auth buttons used on login and sign-up screens.
class SocialProviderButtons extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onGoogle;
  final VoidCallback? onApple;
  /// Divider label, e.g. [context.translate('or')] or [context.translate('or_sign_up_with')].
  final String dividerText;

  const SocialProviderButtons({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.onGoogle,
    required this.dividerText,
    this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? Colors.grey.shade600 : AppColors.borderColor;
    final buttonBackground = isDark ? Colors.grey.shade700 : AppColors.white;
    final labelColor = isDark ? Colors.white : AppColors.googleTextColor;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark ? Colors.grey.shade700 : AppColors.dividerColor,
                thickness: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
              child: Text(
                dividerText,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : AppColors.dividerOrColor,
                ),
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
        const SizedBox(height: AppSpacing.s16),
        CustomButton(
          leading: Image.asset(AppImages.googleLogo),
          showBorder: true,
          borderColor: borderColor,
          text: context.translate('continue_with_google'),
          textColor: labelColor,
          fontFamily: GoogleFonts.inter().fontFamily,
          onPressed: isLoading ? null : onGoogle,
          backgroundColor: buttonBackground,
          useLoadingAnimation: false,
        ),
        if (Platform.isIOS || Platform.isMacOS)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.p12),
            child: CustomButton(
              leading: Transform.scale(
                scale: 1.4,
                child: Image.asset(AppImages.appleLogo),
              ),
              showBorder: true,
              borderColor: borderColor,
              text: context.translate('continue_with_apple'),
              textColor: labelColor,
              fontFamily: GoogleFonts.inter().fontFamily,
              onPressed: isLoading || onApple == null ? null : onApple,
              backgroundColor: buttonBackground,
              useLoadingAnimation: false,
            ),
          ),
      ],
    );
  }
}
