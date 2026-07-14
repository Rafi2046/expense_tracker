import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class AppLockProvider extends ChangeNotifier {
  static const String _enabledKey = 'app_lock_enabled';

  bool _isEnabled = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  bool _suppressNextResume = false;

  bool get isEnabled => _isEnabled;
  bool get isLocked => _isLocked;
  bool get isAuthenticating => _isAuthenticating;

  AppLockProvider() {
    _isEnabled = SharedPrefsHelper.getBool(_enabledKey) ?? false;
    _isLocked = _isEnabled;
  }

  Future<bool> get canCheckBiometrics async {
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  void suppressNextLock() {
    _suppressNextResume = true;
  }

  void lock() {
    if (!_isEnabled) return;
    if (_isAuthenticating) return;

    if (_suppressNextResume) {
      _suppressNextResume = false;
      return;
    }

    _isLocked = true;
    notifyListeners();
  }

  void unlock() {
    _isLocked = false;
    _isAuthenticating = false;
    notifyListeners();
  }

  Future<bool> authenticate() async {
    if (_isAuthenticating) return false;
    if (!_isEnabled || !_isLocked) return true;

    _isAuthenticating = true;
    notifyListeners();

    try {
      final localAuth = LocalAuthentication();
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Authenticate to unlock your BudgetMint',
      );

      if (didAuthenticate) {
        HapticFeedback.lightImpact();
        _isLocked = false;
        _isAuthenticating = false;
        notifyListeners();
        return true;
      } else {
        HapticFeedback.heavyImpact();
        _isAuthenticating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _isAuthenticating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;
    _isEnabled = value;
    await SharedPrefsHelper.setBool(_enabledKey, value);
    if (value) {
      _isLocked = true;
    } else {
      _isLocked = false;
    }
    notifyListeners();
  }
}
