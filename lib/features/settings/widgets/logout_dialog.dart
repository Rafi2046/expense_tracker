import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

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
                color: Color(0xFFFDE8E8), // Light red/pinkish circle
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.activeRed, // Red exit arrow
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle Description
            Text(
              'Are you sure you want to logout?\nYou will need to login again to access your account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.loginSubTitle,
                fontFamily: GoogleFonts.workSans().fontFamily,
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
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF31394D),
                    showBorder: true,
                    borderColor: AppColors.dividerColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: CustomButton(
                    text: 'Logout',
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    backgroundColor: AppColors.activeRed,
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
