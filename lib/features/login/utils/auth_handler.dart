import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/providers/app_lock_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/login/widgets/sync_loading_overlay.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/login/pages/verify_email_screen.dart';

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

  void showError(dynamic e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> autoTriggerBiometric() async {
    HapticFeedback.lightImpact();
    try {
      final success = await context
          .read<BiometricAuthProvider>()
          .authenticate();
      if (!context.mounted) return;
      if (success) {
        _navigateToHome();
      } else {
        HapticFeedback.heavyImpact();
        setBiometricFailed(true);
      }
    } catch (_) {
      if (mounted) setBiometricFailed(true);
    }
  }

  Future<void> handleBiometricTap() async {
    HapticFeedback.lightImpact();
    try {
      final success = await context
          .read<BiometricAuthProvider>()
          .authenticate();
      if (!context.mounted) return;
      if (success) {
        _navigateToHome();
      } else {
        HapticFeedback.heavyImpact();
        setBiometricFailed(true);
      }
    } catch (_) {
      if (mounted) setBiometricFailed(true);
    }
  }

  Future<void> handleEmailLogin({
    required bool biometricMode,
    required String email,
    required String password,
  }) async {
    if (biometricMode) {
      if (password.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('please_enter_password'), style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
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
        if (context.mounted) {
          if (!user.emailVerified) {
            _navigateToVerifyEmail();
          } else {
            _navigateToHome();
          }
        }
      } catch (e) {
        showError(e);
      } finally {
        setLoading(false);
      }
      return;
    }

    if (email.trim().isEmpty || password.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('please_enter_email_password'), style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
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
      if (cred != null && context.mounted) {
        _navigateAfterAuth(cred);
      }
    } catch (e) {
      showError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleGoogleLogin() async {
    setLoading(true);
    try {
      // Avoid app-lock overlay fighting Google's auth UI on resume.
      if (mounted) {
        context.read<AppLockProvider>().suppressNextLock();
      }
      final cred = await _authService.signInWithGoogle();
      if (!mounted || cred == null) return;
      // Defer navigation until after Google UI fully dismisses the frame tree.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigateAfterAuth(cred);
      });
    } catch (e) {
      showError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleAppleLogin() async {
    setLoading(true);
    try {
      if (mounted) {
        context.read<AppLockProvider>().suppressNextLock();
      }
      final cred = await _authService.signInWithApple();
      if (!mounted || cred == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navigateAfterAuth(cred);
      });
    } catch (e) {
      showError(e);
    } finally {
      setLoading(false);
    }
  }

  void _navigateAfterAuth(UserCredential cred) {
    final user = cred.user;
    if (user != null && !user.emailVerified) {
      _navigateToVerifyEmail();
      return;
    }

    final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
    final uid = user?.uid;

    if (isNewUser || uid == null) {
      _navigateToOnboarding();
      return;
    }

    final onboardingDone = SharedPrefsHelper.getBool(
          SharedPrefsHelper.onboardingCompleteKey,
        ) ??
        false;
    if (!onboardingDone) {
      _navigateToOnboarding();
      return;
    }

    final hasSynced =
        SharedPrefsHelper.getBool('has_synced_for_user_$uid') ?? false;
    if (hasSynced) {
      _navigateToHome();
    } else {
      _navigateToSync(uid);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  void _navigateToSync(String uid) {
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

  void _navigateToVerifyEmail() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
    );
  }
}
