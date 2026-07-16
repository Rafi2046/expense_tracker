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
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        debugPrint('Splash screen user reload failed: $e');
      }
    }
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    final currentUser = user;

    if (!currentUser.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VerifyEmailScreen(),
        ),
      );
      return;
    }

    final biometricEnabled = context.read<BiometricAuthProvider>().isEnabled;

    if (biometricEnabled) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(biometricMode: true),
        ),
      );
    } else {
      // Check if the user has completed onboarding
      final onboardingDone = SharedPrefsHelper.getBool(
        SharedPrefsHelper.onboardingCompleteKey,
      );

      if (onboardingDone == true) {
        final hasSynced = SharedPrefsHelper.getBool('has_synced_for_user_${currentUser.uid}') ?? false;
        if (!hasSynced) {
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
