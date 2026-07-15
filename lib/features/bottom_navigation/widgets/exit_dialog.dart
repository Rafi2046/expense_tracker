import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular Logo Icon at the top
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8F5), // Light green circle
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.logOut,
                color: AppColors.activeGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              context.translate('exit_app'),
              style: AppTextStyles.profileTitle.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Subtitle Description
            Text(
              context.translate('exit_confirm'),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontFamily: GoogleFonts.workSans().fontFamily,
                color: AppColors.loginSubTitle,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Actions Row
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: CustomButton(
                    text: context.translate('cancel'),
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF31394D),
                    showBorder: true,
                    borderColor: AppColors.dividerColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Exit Button
                Expanded(
                  child: CustomButton(
                    text: context.translate('exit'),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      SystemNavigator.pop();  // Exit app
                    },
                    backgroundColor: AppColors.activeGreen,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
