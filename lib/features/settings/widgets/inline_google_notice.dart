import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InlineGoogleNotice extends StatelessWidget {
  const InlineGoogleNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dividerColor, width: 1.0),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.g_mobiledata_rounded,
                color: Color(0xFF2E7D32),
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                'Google Sign-in Active',
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your account password is managed securely by Google. You cannot change your Google account credentials inside this app.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: AppColors.loginSubTitle,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
