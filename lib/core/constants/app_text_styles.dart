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

  static TextStyle cardTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    letterSpacing: 1.0,
  );

  static TextStyle cardValueGreen = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonColor,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardValueRed = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.activeRed,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardTrendGreen = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardTrendRed = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeRed,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardStatusText = TextStyle(
    fontSize: 13,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileInfo = TextStyle(
    fontSize: 13,
    color: AppColors.dividerOrColor,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle insightsHeaderTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle summaryCardLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    letterSpacing: 1.0,
  );

  static TextStyle summaryCardValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle summaryCardTrendText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle timeFrameSelectedText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle timeFrameUnselectedText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle sectionHeaderTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle viewAllText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle dialogTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle dialogBody = TextStyle(
    fontSize: 13,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.inter().fontFamily,
    height: 1.4,
  );

  static TextStyle dialogBulletText = TextStyle(
    fontSize: 12,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.inter().fontFamily,
  );

  static TextStyle dialogCloseButton = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonColor,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );
}
