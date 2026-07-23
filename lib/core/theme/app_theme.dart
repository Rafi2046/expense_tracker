import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AppTheme {
  // ── Brand (single primary / secondary pair) ─────────────────────
  static const Color brandPrimaryLight = Color(0xFF0C4E3C);
  static const Color brandPrimaryDark = Color(0xFF2EBD85);
  static const Color brandSecondaryLight = Color(0xFF2EBD85);
  static const Color brandSecondaryDark = Color(0xFF0C4E3C);
  static const Color brandTertiaryLight = Color(0xFF146C48);
  static const Color brandTertiaryDark = Color(0xFF80E2B9);
  static const Color errorColor = Color(0xFFDC3545);

  // ── Scaffold / surface ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF4F6F9);
  static const Color backgroundDark = Color(0xFF0A0E17);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // ── M3 surface containers (replace scattered greys) ─────────────
  static const Color surfaceContainerLowestLight = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowLight = Color(0xFFF4F6F9);
  static const Color surfaceContainerLight = Color(0xFFF1F1F1);
  static const Color surfaceContainerHighLight = Color(0xFFF0F0F0);
  static const Color surfaceContainerHighestLight = Color(0xFFE5E7EB);

  static const Color surfaceContainerLowestDark = Color(0xFF0A0E17);
  static const Color surfaceContainerLowDark = Color(0xFF151B28);
  static const Color surfaceContainerDark = Color(0xFF1E293B);
  static const Color surfaceContainerHighDark = Color(0xFF22262E);
  static const Color surfaceContainerHighestDark = Color(0xFF2D323F);

  // ── Outline / onSurface ─────────────────────────────────────────
  static const Color outlineLight = Color(0xFFE5E7EB);
  static const Color outlineVariantLight = Color(0xFFF0F0F0);
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceVariantLight = Color(0xFF6B7280);

  static const Color outlineDark = Color(0xFF334155);
  static const Color outlineVariantDark = Color(0xFF475569);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);

  // ── Containers ──────────────────────────────────────────────────
  static const Color primaryContainerLight = Color(0xFFE8F8F5);
  static const Color secondaryContainerLight = Color(0xFFD1F2E5);
  static const Color tertiaryContainerLight = Color(0xFFD3EFE8);
  static const Color errorContainerLight = Color(0xFFFEE2E2);

  static const Color primaryContainerDark = Color(0xFF16321F);
  static const Color secondaryContainerDark = Color(0xFF0C4E3C);
  static const Color tertiaryContainerDark = Color(0xFF1D4029);
  static const Color errorContainerDark = Color(0xFF3A1E1A);

  static ColorScheme get lightColorScheme => const ColorScheme.light(
        primary: brandPrimaryLight,
        onPrimary: Colors.white,
        primaryContainer: primaryContainerLight,
        onPrimaryContainer: brandPrimaryLight,
        secondary: brandSecondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainerLight,
        onSecondaryContainer: brandPrimaryLight,
        tertiary: brandTertiaryLight,
        onTertiary: Colors.white,
        tertiaryContainer: tertiaryContainerLight,
        onTertiaryContainer: brandPrimaryLight,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorContainerLight,
        onErrorContainer: errorColor,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        onSurfaceVariant: onSurfaceVariantLight,
        outline: outlineLight,
        outlineVariant: outlineVariantLight,
        surfaceContainerLowest: surfaceContainerLowestLight,
        surfaceContainerLow: surfaceContainerLowLight,
        surfaceContainer: surfaceContainerLight,
        surfaceContainerHigh: surfaceContainerHighLight,
        surfaceContainerHighest: surfaceContainerHighestLight,
      );

  static ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: brandPrimaryDark,
        onPrimary: Colors.white,
        primaryContainer: primaryContainerDark,
        onPrimaryContainer: brandPrimaryDark,
        secondary: brandSecondaryDark,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainerDark,
        onSecondaryContainer: brandPrimaryDark,
        tertiary: brandTertiaryDark,
        onTertiary: backgroundDark,
        tertiaryContainer: tertiaryContainerDark,
        onTertiaryContainer: brandPrimaryDark,
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorContainerDark,
        onErrorContainer: Color(0xFFFCA5A5),
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        onSurfaceVariant: onSurfaceVariantDark,
        outline: outlineDark,
        outlineVariant: outlineVariantDark,
        surfaceContainerLowest: surfaceContainerLowestDark,
        surfaceContainerLow: surfaceContainerLowDark,
        surfaceContainer: surfaceContainerDark,
        surfaceContainerHigh: surfaceContainerHighDark,
        surfaceContainerHighest: surfaceContainerHighestDark,
      );

  /// Reusable card decoration using ColorScheme outline/surface tokens.
  static BoxDecoration cardDecoration({
    required bool isDark,
    double radius = 14,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: isDark ? surfaceDark : surfaceLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? outlineDark : outlineLight,
        width: borderWidth,
      ),
    );
  }

  /// Shared Switch styling — inactive track must stay visible on white cards.
  static SwitchThemeData _switchTheme(ColorScheme scheme, {required bool isLight}) {
    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary.withValues(alpha: isLight ? 0.5 : 0.55);
        }
        // Light: onSurfaceVariant wash — outline/surfaceContainerHighest are too pale on white.
        return isLight
            ? scheme.onSurfaceVariant.withValues(alpha: 0.38)
            : scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return scheme.onSurfaceVariant;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary;
        }
        return isLight ? scheme.onSurfaceVariant : scheme.outline;
      }),
    );
  }

  static ThemeData get lightTheme {
    final scheme = lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      primaryColor: brandPrimaryLight,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
      switchTheme: _switchTheme(scheme, isLight: true),
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: AppFontSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1.0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      primaryColor: brandPrimaryDark,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
      switchTheme: _switchTheme(scheme, isLight: false),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: scheme.onSurface),
        titleMedium: TextStyle(color: scheme.onSurface),
        titleSmall: TextStyle(color: scheme.onSurface),
        bodyLarge: TextStyle(color: scheme.onSurface),
        bodyMedium: TextStyle(color: scheme.onSurface),
        bodySmall: TextStyle(color: scheme.onSurfaceVariant),
        labelLarge: TextStyle(color: scheme.onSurface),
        labelMedium: TextStyle(color: scheme.onSurfaceVariant),
        labelSmall: TextStyle(color: scheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outline, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: AppFontSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: scheme.onSurface),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
