import 'package:flutter/material.dart';

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
  );

  /// Section headers, dialog titles (size18, bold)
  static TextStyle h2 = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,

  );

  /// Card titles, subsection headers (size16, w600)
  static TextStyle h3 = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,

  );

  /// Primary body text (size14, w400, inter)
  static TextStyle body = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,

    color: AppColors.loginSubTitle,
  );

  /// Emphasized body (size14, w600)
  static TextStyle bodyBold = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,

  );

  /// Secondary body text (size13, w400)
  static TextStyle bodySmall = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.w400,
    color: AppColors.loginSubTitle,

  );

  /// Form labels, badges, metadata (size12, w500, sans)
  static TextStyle label = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,

  );

  /// Smallest labels, timestamps (size11)
  static TextStyle caption = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,

  );

  /// Hero amounts, display numbers (size24, bold)
  static TextStyle displayMedium = TextStyle(
    fontSize: AppFontSizes.size24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,

  );

  /// Large display values (size28, bold)
  static TextStyle displayLarge = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
    color: AppColors.black,

  );

  // ──────────────────────────────────────────────
  // Named styles — kept for backward compatibility
  // ──────────────────────────────────────────────

  // Splash
  static TextStyle splashTextTitle = TextStyle(
    fontSize: AppFontSizes.size18,

    color: AppColors.splashColor,
    fontWeight: FontWeight.w400,
  );


  static TextStyle splashTextSubTitle = TextStyle(
    fontSize: AppFontSizes.size16,

    color: AppColors.splashColor,
    fontWeight: FontWeight.w400,
  );

  // Auth
  static TextStyle loginTitle = TextStyle(
    fontSize: AppFontSizes.size32,

    color: AppColors.loginTitle,
    fontWeight: FontWeight.w600,
  );

  static TextStyle loginSubTitle = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.loginSubTitle,
    fontWeight: FontWeight.w400,
  );

  static TextStyle textFieldLabel = TextStyle(
    fontSize: AppFontSizes.size12,

    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle textFieldLabelPassword = TextStyle(
    fontSize: AppFontSizes.size12,

    color: AppColors.loginLabelPasswordColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle textFieldHint = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle signUpText = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.loginLabelPasswordColor,
    fontWeight: FontWeight.w400,
  );

  static TextStyle accountText = TextStyle(
    fontSize: AppFontSizes.size14,

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

  );

  static TextStyle profileSubtitle = TextStyle(
    fontSize: AppFontSizes.size14,
    color: AppColors.loginSubTitle,

  );

  static TextStyle profileCardTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,

  );

  static TextStyle profileCardSubtitle = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.loginSubTitle,

  );

  static TextStyle createProfile = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.bold,

    color: AppColors.selectedColor,
  );

  static TextStyle profileInfo = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.dividerOrColor,

  );

  // Cards
  static TextStyle cardTitle = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,

    letterSpacing: 1.0,
  );

  static TextStyle cardValueGreen = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,

  );

  static TextStyle cardValueRed = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppColors.activeRed,

  );

  static TextStyle cardTrendGreen = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,

  );

  static TextStyle cardTrendRed = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeRed,

  );

  static TextStyle cardStatusText = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.loginSubTitle,

  );

  // Insights / Summary
  static TextStyle insightsHeaderTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,

  );

  static TextStyle summaryCardLabel = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,

    letterSpacing: 1.0,
  );

  static TextStyle summaryCardValue = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,

  );

  static TextStyle summaryCardTrendText = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppColors.activeGreen,

  );

  // Time Frame
  static TextStyle timeFrameSelectedText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: Colors.white,

  );

  static TextStyle timeFrameUnselectedText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,

  );

  // Sections
  static TextStyle sectionHeaderTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,

  );

  static TextStyle viewAllText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: AppColors.activeGreen,

  );

  // Dialogs
  static TextStyle dialogTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: AppColors.black,

  );

  static TextStyle dialogBody = TextStyle(
    fontSize: AppFontSizes.size13,
    color: AppColors.loginSubTitle,

    height: 1.4,
  );

  static TextStyle dialogBulletText = TextStyle(
    fontSize: AppFontSizes.size12,
    color: AppColors.loginSubTitle,

  );

  static TextStyle dialogCloseButton = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonColor,

  );

  // Calculator
  static TextStyle calculatorTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,

  );

  static TextStyle calculatorLabel = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.w600,
    color: Colors.black54,

  );

  static TextStyle calculatorInputText = TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.bold,
    color: Colors.black87,

  );

  static TextStyle calculatorResultAmount = TextStyle(
    fontSize: AppFontSizes.size32,
    fontWeight: FontWeight.bold,
    color: Colors.white,

  );

  static TextStyle calculatorResultLabel = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.bold,
    color: Colors.white70,

    letterSpacing: 1.5,
  );

  // Party
  static TextStyle partyFormLabel = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.loginLabelColor,
    fontWeight: FontWeight.w500,
  );

  static TextStyle partyFormInput = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.loginTitle,
    fontWeight: FontWeight.w400,
  );

  static TextStyle partyFormHint = TextStyle(
    fontSize: AppFontSizes.size10,

    color: Colors.grey.shade400,
    fontWeight: FontWeight.w400,
  );

  static TextStyle partyTabActive = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.activeGreen,
    fontWeight: FontWeight.w600,
  );

  static TextStyle partyTabInactive = TextStyle(
    fontSize: AppFontSizes.size14,

    color: AppColors.loginSubTitle,
    fontWeight: FontWeight.w500,
  );

  static TextStyle partySubmitButtonText = TextStyle(
    fontSize: AppFontSizes.size16,

    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  // Reports
  static TextStyle reportAppBarTitle = TextStyle(
    fontSize: AppFontSizes.size18,

    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportAppBar = TextStyle(
    fontSize: AppFontSizes.size18,

    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  static TextStyle reportSectionHeader = TextStyle(
    fontSize: AppFontSizes.size14,

    fontWeight: FontWeight.bold,
    color: Colors.grey.shade500,
  );

  static TextStyle reportTileTitle = TextStyle(
    fontSize: AppFontSizes.size15,

    fontWeight: FontWeight.w600,
    color: const Color(0xFF31394D),
  );

  static TextStyle reportLargeValue = TextStyle(
    fontSize: AppFontSizes.size28,

    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportStatLabel = TextStyle(
    fontSize: AppFontSizes.size11,

    fontWeight: FontWeight.bold,
    color: Colors.grey.shade400,
  );

  static TextStyle reportStatValue = TextStyle(
    fontSize: AppFontSizes.size18,

    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportTransactionTitle = TextStyle(
    fontSize: AppFontSizes.size15,

    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static TextStyle reportTransactionSubtitle = TextStyle(
    fontSize: AppFontSizes.size12,

    color: Colors.grey.shade500,
  );
}
