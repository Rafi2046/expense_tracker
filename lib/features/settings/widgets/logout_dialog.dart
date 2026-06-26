import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : AppColors.dividerColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: theme.cardColor,
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
              decoration: BoxDecoration(
                color: isDark ? Colors.red.withValues(alpha: 0.15) : const Color(0xFFFDE8E8), // Light red/pinkish circle
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.logout,
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
                color: theme.colorScheme.onSurface,
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
                color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
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
                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    textColor: theme.colorScheme.onSurface,
                    showBorder: true,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: CustomButton(
                    text: 'Logout',
                    onPressed: () async {
                      try {
                        await AuthService().signOut();
                      } catch (e) {
                        // Ignore sign out errors so navigation always proceeds
                      }
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
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
