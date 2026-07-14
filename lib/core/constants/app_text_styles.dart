import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_font_sizes.dart';

class AppTextStyles {
  // ──────────────────────────────────────────────
  // Semantic roles — use these for consistency
  // ──────────────────────────────────────────────

  /// Page titles, appbar titles (size20, w600)
  static TextStyle h1 = TextStyle(
    fontSize: AppFontSizes.size20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Section headers, dialog titles (size18, bold)
  static TextStyle h2 = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Card titles, subsection headers (size16, w600)
  static TextStyle h3 = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Primary body text (size14, w400, inter)
  static TextStyle body = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginSubTitle,
  );

  /// Emphasized body (size14, w600)
  static TextStyle bodyBold = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Secondary body text (size13, w400)
  static TextStyle bodySmall = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.w400,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Form labels, badges, metadata (size12, w500, sans)
  static TextStyle label = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Smallest labels, timestamps (size11)
  static TextStyle caption = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Hero amounts, display numbers (size24, bold)
  static TextStyle displayMedium = TextStyle(
    fontSize: AppFontSizes.size24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  /// Large display values (size28, bold)
  static TextStyle displayLarge = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // ──────────────────────────────────────────────
  // Named styles — kept for backward compatibility
  // ──────────────────────────────────────────────

  // Splash
  static TextStyle splashTextTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.splashColor,
    fontWeight: FontWeight.w400,
  );


  static TextStyle splashTextSubTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.splashColor,
    fontWeight: FontWeight.w400,
  );

  // Auth
  static TextStyle loginTitle = TextStyle(
    fontSize: AppFontSizes.size32,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.loginTitle,
    fontWeight: FontWeight.w600,
  );

  static TextStyle loginSubTitle = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginSubTitle,
    fontWeight: FontWeight.w400,
  );

  static TextStyle textFieldLabel = TextStyle(
    fontSize: AppFontSizes.size12,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle textFieldLabelPassword = TextStyle(
    fontSize: AppFontSizes.size12,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    color: AppColors.loginLabelPasswordColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle textFieldHint = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle signUpText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.loginLabelPasswordColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle accountText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.inter().fontFamily,
    color: AppColors.dividerOrColor,
    fontWeight: FontWeight.w400,
  );

  // AppBar
  static TextStyle appbarTitle = TextStyle(
    fontSize: AppFontSizes.size20,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  // Profile
  static TextStyle profileTitle = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileSubtitle = TextStyle(
    fontSize: AppFontSizes.size14,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileCardTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle profileCardSubtitle = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle createProfile = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.bold,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.selectedColor,
  );

  static TextStyle profileInfo = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.dividerOrColor,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // Cards
  static TextStyle cardTitle = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    letterSpacing: 1.0,
  );

  static TextStyle cardValueGreen = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardValueRed = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppColors.activeRed,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardTrendGreen = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardTrendRed = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeRed,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle cardStatusText = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // Insights / Summary
  static TextStyle insightsHeaderTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle summaryCardLabel = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    letterSpacing: 1.0,
  );

  static TextStyle summaryCardValue = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle summaryCardTrendText = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // Time Frame
  static TextStyle timeFrameSelectedText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle timeFrameUnselectedText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // Sections
  static TextStyle sectionHeaderTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle viewAllText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: AppColors.activeGreen,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // Dialogs
  static TextStyle dialogTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle dialogBody = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.inter().fontFamily,
    height: 1.4,
  );

  static TextStyle dialogBulletText = TextStyle(
    fontSize: AppFontSizes.size12,
    color: AppColors.loginSubTitle,
    fontFamily: GoogleFonts.inter().fontFamily,
  );

  static TextStyle dialogCloseButton = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonColor,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  // Calculator
  static TextStyle calculatorTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle calculatorLabel = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle calculatorInputText = TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  );

  static TextStyle calculatorResultAmount = TextStyle(
    fontSize: AppFontSizes.size32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: GoogleFonts.workSans().fontFamily,
  );

  static TextStyle calculatorResultLabel = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.bold,
    color: Colors.white70,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
    letterSpacing: 1.5,
  );

  // Party
  static TextStyle partyFormLabel = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle partyFormInput = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.loginTitle,
    fontWeight: FontWeight.w400,
  );

  static TextStyle partyFormHint = TextStyle(
    fontSize: AppFontSizes.size10,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: Colors.grey.shade400,
    fontWeight: FontWeight.w400,
  );

  static TextStyle partyTabActive = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.activeGreen,
    fontWeight: FontWeight.w600,
  );

  static TextStyle partyTabInactive = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: AppColors.loginSubTitle,
    fontWeight: FontWeight.w500,
  );

  static TextStyle partySubmitButtonText = TextStyle(
    fontSize: AppFontSizes.size16,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  // Reports
  static TextStyle reportAppBarTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportAppBar = TextStyle(
    fontSize: AppFontSizes.size18,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  static TextStyle reportSectionHeader = TextStyle(
    fontSize: AppFontSizes.size14,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade500,
  );

  static TextStyle reportTileTitle = TextStyle(
    fontSize: AppFontSizes.size15,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF31394D),
  );

  static TextStyle reportLargeValue = TextStyle(
    fontSize: AppFontSizes.size28,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportStatLabel = TextStyle(
    fontSize: AppFontSizes.size11,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade400,
  );

  static TextStyle reportStatValue = TextStyle(
    fontSize: AppFontSizes.size18,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportTransactionTitle = TextStyle(
    fontSize: AppFontSizes.size15,
    fontFamily: GoogleFonts.workSans().fontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportTransactionSubtitle = TextStyle(
    fontSize: AppFontSizes.size12,
    fontFamily: GoogleFonts.workSans().fontFamily,
    color: Colors.grey.shade500,
  );
}
