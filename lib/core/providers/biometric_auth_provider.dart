import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';

class BiometricAuthProvider extends ChangeNotifier {
  static const String _enabledKey = 'biometric_login_enabled';
  static const String _emailKey = 'biometric_login_email';

  bool _isEnabled = false;
  IconData _icon = Icons.fingerprint;

  bool get isEnabled => _isEnabled;
  IconData get icon => _icon;

  BiometricAuthProvider() {
    _isEnabled = SharedPrefsHelper.getBool(_enabledKey) ?? false;
  }

  Future<bool> get canCheckBiometrics async {
    try {
      final localAuth = LocalAuthentication();
      return await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<void> detectBiometrics() async {
    try {
      final localAuth = LocalAuthentication();
      final available = await localAuth.getAvailableBiometrics();
      if (available.contains(BiometricType.face)) {
        _icon = Icons.face_rounded;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> authenticate({String localizedReason = 'Use biometrics to unlock your expense tracker'}) async {
    final localAuth = LocalAuthentication();
    return await localAuth.authenticate(
      localizedReason: localizedReason,
      biometricOnly: true,
    );
  }

  Future<void> setEnabled(bool value, {String? email}) async {
    if (_isEnabled == value) return;
    _isEnabled = value;
    await SharedPrefsHelper.setBool(_enabledKey, value);
    if (value && email != null) {
      await SharedPrefsHelper.setString(_emailKey, email);
    } else if (!value) {
      await SharedPrefsHelper.remove(_emailKey);
    }
    notifyListeners();
  }
}
