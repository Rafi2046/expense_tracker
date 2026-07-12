import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingNavigationButtons extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const OnboardingNavigationButtons({
    super.key,
    required this.isLastPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLastPage ? AppColors.activeGreen : AppColors.buttonColor,
          foregroundColor: Colors.white,
          elevation: isLastPage ? 6 : 2,
          shadowColor: AppColors.activeGreen.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage
                  ? context.translate('onboarding_get_started')
                  : context.translate('onboarding_next'),
              style: AppTextStyles.reportTileTitle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLastPage ? LucideIcons.rocket : LucideIcons.arrowRight,
              size: 18,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
