import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/login/widgets/sync_loading_overlay.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';

mixin AuthHandler<T extends StatefulWidget> on State<T> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _biometricFailed = false;

  bool get isLoading => _isLoading;
  bool get biometricFailed => _biometricFailed;

  bool get hasPasswordProvider {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  void setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  void setBiometricFailed(bool v) {
    if (mounted) setState(() => _biometricFailed = v);
  }

  void showError(BuildContext context, dynamic e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
    );
  }

  Future<void> autoTriggerBiometric(BuildContext context) async {
    HapticFeedback.lightImpact();
    try {
      final success = await context
          .read<BiometricAuthProvider>()
          .authenticate();
      if (!mounted) return;
      if (success) {
        _navigateToHome(context);
      } else {
        HapticFeedback.heavyImpact();
        setBiometricFailed(true);
      }
    } catch (_) {
      if (mounted) setBiometricFailed(true);
    }
  }

  Future<void> handleBiometricTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    try {
      final success = await context
          .read<BiometricAuthProvider>()
          .authenticate();
      if (!mounted) return;
      if (success) {
        _navigateToHome(context);
      } else {
        HapticFeedback.heavyImpact();
        setBiometricFailed(true);
      }
    } catch (_) {
      if (mounted) setBiometricFailed(true);
    }
  }

  Future<void> handleEmailLogin({
    required BuildContext context,
    required bool biometricMode,
    required String email,
    required String password,
  }) async {
    if (biometricMode) {
      if (password.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your password')),
          );
        }
        return;
      }
      setLoading(true);
      try {
        final user = FirebaseAuth.instance.currentUser!;
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: password.trim(),
          ),
        );
        if (mounted) _navigateToHome(context);
      } catch (e) {
        showError(context, e);
      } finally {
        setLoading(false);
      }
      return;
    }

    if (email.trim().isEmpty || password.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both email and password')),
        );
      }
      return;
    }

    setLoading(true);
    try {
      final cred = await _authService.loginWithEmail(
        email.trim(),
        password.trim(),
      );
      if (cred != null && mounted) {
        _navigateAfterAuth(context, cred);
      }
    } catch (e) {
      showError(context, e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleGoogleLogin(BuildContext context) async {
    setLoading(true);
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred != null && mounted) {
        _navigateAfterAuth(context, cred);
      }
    } catch (e) {
      showError(context, e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleAppleLogin(BuildContext context) async {
    setLoading(true);
    try {
      final cred = await _authService.signInWithApple();
      if (cred != null && mounted) {
        _navigateAfterAuth(context, cred);
      }
    } catch (e) {
      showError(context, e);
    } finally {
      setLoading(false);
    }
  }

  void _navigateAfterAuth(BuildContext context, UserCredential cred) {
    final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (isNewUser || uid == null) {
      _navigateToOnboarding(context);
      return;
    }

    _navigateToSync(context, uid);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _navigateToSync(BuildContext context, String uid) {
    final syncService = SyncService();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SyncLoadingOverlay(
          syncService: syncService,
          uid: uid,
        ),
      ),
    );
  }
}
