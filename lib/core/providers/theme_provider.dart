import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = SharedPrefsHelper.getString(_prefsKey);
    if (savedMode != null) {
      switch (savedMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      
      String val;
      switch (mode) {
        case ThemeMode.light:
          val = 'light';
          break;
        case ThemeMode.dark:
          val = 'dark';
          break;
        case ThemeMode.system:
          val = 'system';
          break;
      }

      SharedPrefsHelper.setString(_prefsKey, val);
    }
  }
}
