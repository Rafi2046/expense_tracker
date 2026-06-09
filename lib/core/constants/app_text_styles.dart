import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle splashTextTitle = TextStyle(
    fontSize: 16,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.splash,
    fontWeight: FontWeight.w600,
  );

  static TextStyle splashTextSubTitle = TextStyle(
    fontSize: 16,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.splashColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle loginTitle = TextStyle(
    fontSize: 30,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.loginTitle,
    fontWeight: FontWeight.w600,
  );
  static TextStyle loginSubTitle = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginSubTitle,
    fontWeight: FontWeight.w400,
  );
}
