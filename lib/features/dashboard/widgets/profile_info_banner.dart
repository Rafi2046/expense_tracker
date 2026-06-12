import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInfoBanner extends StatelessWidget {
  const ProfileInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.infoBannerBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: Color(0xFF565E74),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You can also create & manage multiple profiles from the homepage later.',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF565E74),
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
