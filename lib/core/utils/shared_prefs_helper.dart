import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  /// Key used to persist the last active profile ID across restarts.
  static const String activeProfileKey = 'active_profile_id';

  static SharedPreferences? _prefs;

  // Initialize the SharedPreferences instance.
  // This should be called in main() before runApp().
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save a string value.
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // Get a string value.
  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  // Save a boolean value.
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // Get a boolean value.
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Remove a specific key.
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear all preferences.
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
