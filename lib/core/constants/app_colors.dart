import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

/// Semantic aliases aligned with [AppTheme] ColorScheme.
/// Prefer `Theme.of(context).colorScheme` in widgets; use these only where
/// a [BuildContext] is unavailable (static styles, non-widget helpers).
class AppColors {
  // ── Brand (merged greens → primary / secondary) ─────────────────
  static const Color buttonColor = AppTheme.brandPrimaryLight;
  static const Color activeGreen = AppTheme.brandPrimaryDark;
  static const Color selectedColor = AppTheme.brandPrimaryDark;
  static const Color notificationIcon = AppTheme.brandPrimaryLight;
  static const Color loginLabelPasswordColor = AppTheme.brandPrimaryLight;

  // ── Error (single red) ──────────────────────────────────────────
  static const Color activeRed = AppTheme.errorColor;
  static const Color expensePink = AppTheme.errorColor;

  // ── Neutrals matching ColorScheme light roles ───────────────────
  static const Color borderColor = AppTheme.onSurfaceVariantLight;
  static const Color textMuted = AppTheme.onSurfaceVariantLight;
  static const Color loginLabelColor = AppTheme.onSurfaceVariantLight;
  static const Color loginTitle = AppTheme.onSurfaceLight;
  static const Color googleTextColor = AppTheme.onSurfaceLight;
  static const Color loginSubTitle = AppTheme.onSurfaceVariantLight;
  static const Color dividerOrColor = AppTheme.onSurfaceVariantLight;
  static const Color dividerColor = AppTheme.outlineLight;
  static const Color containerColorGrey = AppTheme.surfaceContainerLight;
  static const Color selectionGreenBg = AppTheme.primaryContainerLight;
  static const Color infoBannerBackground = AppTheme.surfaceContainerLowLight;
  static const Color chipBackground = AppTheme.surfaceContainerLight;

  // ── Absolute (legacy splash / login) ────────────────────────────
  static const Color splash = Color(0xFF191C1D);
  static const Color splashColor = Color(0xFF3C4A42);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
