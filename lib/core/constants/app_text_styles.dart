import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'app_font_sizes.dart';

/// Semantic text styles — sizes/weights only.
///
/// Do **not** bake in light-theme greys/blacks. Colors come from
/// [ThemeData.textTheme] / [ColorScheme] via inheritance, or
/// `.copyWith(color: Theme.of(context).colorScheme.onSurface)` at the call site.
///
/// Brand accents (primary / error / onPrimary) use [AppTheme] tokens so they
/// stay aligned with the Material 3 ColorScheme.
class AppTextStyles {
  AppTextStyles._();

  // ──────────────────────────────────────────────
  // Semantic roles
  // ──────────────────────────────────────────────

  /// Page titles, appbar titles (size20, w600)
  static const TextStyle h1 = TextStyle(
    fontSize: AppFontSizes.size20,
    fontWeight: FontWeight.w600,
  );

  /// Section headers, dialog titles (size18, bold)
  static const TextStyle h2 = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  /// Card titles, subsection headers (size16, w600)
  static const TextStyle h3 = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w600,
  );

  /// Primary body text (size14, w400)
  static const TextStyle body = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
  );

  /// Emphasized body (size14, w600)
  static const TextStyle bodyBold = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
  );

  /// Secondary body text (size13, w400)
  static const TextStyle bodySmall = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.w400,
  );

  /// Form labels, badges, metadata (size12, w500)
  static const TextStyle label = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.w500,
  );

  /// Smallest labels, timestamps (size11)
  static const TextStyle caption = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.w400,
  );

  /// Hero amounts, display numbers (size24, bold)
  static const TextStyle displayMedium = TextStyle(
    fontSize: AppFontSizes.size24,
    fontWeight: FontWeight.bold,
  );

  /// Large display values (size28, bold)
  static const TextStyle displayLarge = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
  );

  // ──────────────────────────────────────────────
  // Named styles — backward compatible (no baked greys)
  // ──────────────────────────────────────────────

  static const TextStyle splashTextTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle splashTextSubTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle loginTitle = TextStyle(
    fontSize: AppFontSizes.size32,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle loginSubTitle = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textFieldLabel = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle textFieldLabelPassword = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.w500,
    color: AppTheme.brandPrimaryLight,
  );

  static const TextStyle textFieldHint = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle signUpText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
    color: AppTheme.brandPrimaryLight,
  );

  static const TextStyle accountText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle appbarTitle = TextStyle(
    fontSize: AppFontSizes.size20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle profileTitle = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle profileSubtitle = TextStyle(
    fontSize: AppFontSizes.size14,
  );

  static const TextStyle profileCardTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle profileCardSubtitle = TextStyle(
    fontSize: AppFontSizes.size13,
  );

  static const TextStyle createProfile = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.bold,
    color: AppTheme.brandPrimaryDark,
  );

  static const TextStyle profileInfo = TextStyle(
    fontSize: AppFontSizes.size13,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static const TextStyle cardValueGreen = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppTheme.brandPrimaryDark,
  );

  static const TextStyle cardValueRed = TextStyle(
    fontSize: AppFontSizes.size22,
    fontWeight: FontWeight.bold,
    color: AppTheme.errorColor,
  );

  static const TextStyle cardTrendGreen = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppTheme.brandPrimaryDark,
  );

  static const TextStyle cardTrendRed = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppTheme.errorColor,
  );

  static const TextStyle cardStatusText = TextStyle(
    fontSize: AppFontSizes.size13,
  );

  static const TextStyle insightsHeaderTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle summaryCardLabel = TextStyle(
    fontSize: AppFontSizes.size12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static const TextStyle summaryCardValue = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
    color: AppTheme.brandPrimaryDark,
  );

  static const TextStyle summaryCardTrendText = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.bold,
    color: AppTheme.brandPrimaryDark,
  );

  static const TextStyle timeFrameSelectedText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle timeFrameUnselectedText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionHeaderTitle = TextStyle(
    fontSize: AppFontSizes.size16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle viewAllText = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w600,
    color: AppTheme.brandPrimaryDark,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogBody = TextStyle(
    fontSize: AppFontSizes.size13,
    height: 1.4,
  );

  static const TextStyle dialogBulletText = TextStyle(
    fontSize: AppFontSizes.size12,
  );

  static const TextStyle dialogCloseButton = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.bold,
    color: AppTheme.brandPrimaryLight,
  );

  static const TextStyle calculatorTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle calculatorLabel = TextStyle(
    fontSize: AppFontSizes.size13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle calculatorInputText = TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle calculatorResultAmount = TextStyle(
    fontSize: AppFontSizes.size32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle calculatorResultLabel = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.bold,
    color: Colors.white70,
    letterSpacing: 1.5,
  );

  static const TextStyle partyFormLabel = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle partyFormInput = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle partyFormHint = TextStyle(
    fontSize: AppFontSizes.size10,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle partyTabActive = TextStyle(
    fontSize: AppFontSizes.size14,
    color: AppTheme.brandPrimaryDark,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle partyTabInactive = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle partySubmitButtonText = TextStyle(
    fontSize: AppFontSizes.size16,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle reportAppBarTitle = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportAppBar = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportSectionHeader = TextStyle(
    fontSize: AppFontSizes.size14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportTileTitle = TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle reportLargeValue = TextStyle(
    fontSize: AppFontSizes.size28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportStatLabel = TextStyle(
    fontSize: AppFontSizes.size11,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportStatValue = TextStyle(
    fontSize: AppFontSizes.size18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportTransactionTitle = TextStyle(
    fontSize: AppFontSizes.size15,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reportTransactionSubtitle = TextStyle(
    fontSize: AppFontSizes.size12,
  );
}
