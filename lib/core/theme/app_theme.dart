import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AppTheme {
  // Brand Colors
  static const Color brandPrimaryLight = Color(0xFF0C4E3C);
  static const Color brandPrimaryDark = Color(0xFF2EBD85);
  
  static const Color backgroundLight = Color(0xFFF4F6F9);
  static const Color backgroundDark = Color(0xFF0A0E17);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // Reusable card decoration for the layered navy look
  static BoxDecoration cardDecoration({
    required bool isDark,
    double radius = 14,
    double borderWidth = 1,
  }) {
    if (!isDark) {
      return BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE5E7EB), width: borderWidth),
      );
    }
    return BoxDecoration(
      color: surfaceDark,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFF334155), width: borderWidth),
    );
  }

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: brandPrimaryLight,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: brandPrimaryLight,
        secondary: Color(0xFF2EBD85),
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSurface: Colors.black87,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: AppFontSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0F0F0),
        thickness: 1.0,
      ),
    );
  }

  // Dark Theme Configuration — Layered Navy
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: brandPrimaryDark,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: brandPrimaryDark,
        secondary: Color(0xFF0C4E3C),
        surface: surfaceDark,
        error: Color(0xFFDC3545),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
        titleSmall: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Color(0xFF94A3B8)),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Color(0xFF94A3B8)),
        labelSmall: TextStyle(color: Color(0xFF94A3B8)),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
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
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: AppFontSizes.size18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2EBD85), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF334155),
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: Color(0xFF475569)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2EBD85),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Sample card usage demonstrating the layered navy design:
  ///
  /// ```dart
  /// Container(
  ///   decoration: AppTheme.cardDecoration(isDark: isDark),
  ///   padding: const EdgeInsets.all(16),
  ///   child: Column(
  ///     crossAxisAlignment: CrossAxisAlignment.start,
  ///     children: [
  ///       Text('Card Title', style: Theme.of(context).textTheme.titleMedium),
  ///       const SizedBox(height: 4),
  ///       Text('Secondary text description',
  ///         style: Theme.of(context).textTheme.bodySmall),
  ///     ],
  ///   ),
  /// )
  /// ```
}
