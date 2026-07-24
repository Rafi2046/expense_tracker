import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/login/pages/verify_email_screen.dart';
import 'package:expense_tracker/features/login/widgets/sync_loading_overlay.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateAfterDelay());
  }

  Future<void> _navigateAfterDelay() async {
    debugPrint('Splash: starting navigation check');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    var user = FirebaseAuth.instance.currentUser;
    debugPrint('Splash: currentUser is $user');
    if (user != null) {
      try {
        debugPrint('Splash: reloading user...');
        await user.reload().timeout(const Duration(seconds: 3));
        user = FirebaseAuth.instance.currentUser;
        debugPrint('Splash: reload successful. user is now $user');
      } catch (e) {
        debugPrint('Splash screen user reload failed or timed out: $e');
      }
    }
    if (!mounted) return;

    if (user == null) {
      debugPrint('Splash: no user found, navigating to LoginScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    final currentUser = user;
    debugPrint('Splash: user is authenticated. Email verified: ${currentUser.emailVerified}');

    if (!currentUser.emailVerified) {
      debugPrint('Splash: email not verified, navigating to VerifyEmailScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VerifyEmailScreen(),
        ),
      );
      return;
    }

    debugPrint('Splash: checking biometrics...');
    final biometricEnabled = context.read<BiometricAuthProvider>().isEnabled;
    debugPrint('Splash: biometricEnabled: $biometricEnabled');

    if (biometricEnabled) {
      debugPrint('Splash: biometric enabled, navigating to LoginScreen in biometric mode');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(biometricMode: true),
        ),
      );
    } else {
      debugPrint('Splash: checking onboarding...');
      final onboardingDone = SharedPrefsHelper.getBool(
        SharedPrefsHelper.onboardingCompleteKey,
      );
      debugPrint('Splash: onboardingDone: $onboardingDone');

      if (onboardingDone == true) {
        final hasSynced = SharedPrefsHelper.getBool('has_synced_for_user_${currentUser.uid}') ?? false;
        debugPrint('Splash: sync status: hasSynced = $hasSynced');
        if (!hasSynced) {
          debugPrint('Splash: user not synced, navigating to SyncLoadingOverlay');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SyncLoadingOverlay(
                syncService: SyncService(),
                uid: currentUser.uid,
              ),
            ),
          );
        } else {
          debugPrint('Splash: user synced, navigating to BottomNavScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavScreen()),
          );
        }
      } else {
        debugPrint('Splash: onboarding not done, navigating to OnboardingScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SplashScreen: build called');
    return Scaffold(
      // Match Android LaunchTheme / NormalTheme splash_background so the
      // handoff from native → Flutter has no white flash.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(AppImages.splashLogo, width: 150, height: 150),
          ),
        ],
      ),
    );
  }
}
