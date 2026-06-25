import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color brandPrimaryLight = Color(0xFF0C4E3C);
  static const Color brandPrimaryDark = Color(0xFF2EBD85);
  
  static const Color backgroundLight = Color(0xFFF4F6F9);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

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
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF0F0F0),
        thickness: 1.0,
      ),
    );
  }

  // Dark Theme Configuration
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
        onPrimary: Colors.black87,
        onSurface: Colors.white70,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2D2D),
        thickness: 1.0,
      ),
    );
  }
}
