import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class PrivacyProvider extends ChangeNotifier {
  static const String _key = 'privacy_mode_masked';

  bool _isMasked = false;

  bool get isMasked => _isMasked;

  PrivacyProvider() {
    _isMasked = SharedPrefsHelper.getBool(_key) ?? false;
  }

  Future<void> toggle() async {
    _isMasked = !_isMasked;
    await SharedPrefsHelper.setBool(_key, _isMasked);
    notifyListeners();
  }

  Future<void> setMasked(bool value) async {
    if (_isMasked == value) return;
    _isMasked = value;
    await SharedPrefsHelper.setBool(_key, _isMasked);
    notifyListeners();
  }

  Future<void> enable() => setMasked(true);
  Future<void> disable() => setMasked(false);
}
