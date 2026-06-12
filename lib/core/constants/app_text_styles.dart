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
  static TextStyle textFieldLabel = TextStyle(
    fontSize: 12,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textFieldHint = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle textFieldLabelPassword = TextStyle(
    fontSize: 12,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    color: AppColors.loginLabelPasswordColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle signUpText = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginLabelPasswordColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle accountText = TextStyle(
    fontSize: 14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.dividerOrColor,
    fontWeight: FontWeight.w400,
  );
  static TextStyle appbarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle profileTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileSubtitle = TextStyle(
    fontSize: 14,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileCardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileCardSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle createProfile = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.selectedColor,
  );
  static TextStyle profileInfo = TextStyle(
    fontSize: 13,
    color: AppColors.dividerOrColor,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );
}
