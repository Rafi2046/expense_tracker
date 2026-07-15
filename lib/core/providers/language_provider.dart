import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppLanguage {
  final String code;
  final String name;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LanguageProvider extends ChangeNotifier {
  final List<AppLanguage> supportedLanguages = const [
    AppLanguage(code: 'en', name: 'English', flag: '🇺🇸'),
    AppLanguage(code: 'bn', name: 'Bangla', flag: '🇧🇩'),
    AppLanguage(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
    AppLanguage(code: 'ur', name: 'Urdu', flag: '🇵🇰'),
  ];

  String _currentLanguageCode = 'en';

  String get currentLanguageCode => _currentLanguageCode;

  AppLanguage get currentLanguage {
    return supportedLanguages.firstWhere(
      (l) => l.code == _currentLanguageCode,
      orElse: () => supportedLanguages.first,
    );
  }

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() {
    final savedCode = SharedPrefsHelper.getString('app_language_code');
    if (savedCode != null) {
      _currentLanguageCode = savedCode;
    }
  }

  Future<void> changeLanguage(String code, BuildContext context) async {
    if (_currentLanguageCode != code) {
      _currentLanguageCode = code;
      await SharedPrefsHelper.setString('app_language_code', code);
      if (context.mounted) {
        await context.setLocale(Locale(code));
      }
      notifyListeners();
    }
  }

  String translate(String key) {
    return tr(key);
  }
}

extension TranslationExtension on BuildContext {
  String translate(String key, {bool listen = true}) {
    return tr(key);
  }
}
