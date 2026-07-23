import 'dart:async';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/sync_loading_overlay.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/pages/create_account_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final bool isFromSignup;

  const VerifyEmailScreen({super.key, this.isFromSignup = false});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  Timer? _timer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _isReloading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Auto-send verification email on signup if not already verified
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified && widget.isFromSignup) {
      _sendVerificationEmailSilently();
    }
    // Start polling to check if email has been verified
    _startVerificationCheckTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheckTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser != null && refreshedUser.emailVerified) {
          _timer?.cancel();
          _navigateToNextScreen();
        }
      }
    });
  }

  Future<void> _sendVerificationEmailSilently() async {
    try {
      await _authService.sendEmailVerification();
    } catch (_) {
      // Fail silently for automatic triggering, user can trigger manually
    }
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        _cooldownTimer?.cancel();
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.sendEmailVerification();
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('verification_link_sent')),
            backgroundColor: AppColors.activeGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.activeRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_isReloading) return;

    setState(() {
      _isReloading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser != null && refreshedUser.emailVerified) {
          _timer?.cancel();
          _navigateToNextScreen();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('email_not_verified')),
                backgroundColor: AppColors.dividerOrColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.activeRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReloading = false;
        });
      }
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final onboardingDone =
        SharedPrefsHelper.getBool(SharedPrefsHelper.onboardingCompleteKey) ??
        false;

    if (widget.isFromSignup || !onboardingDone) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SyncLoadingOverlay(syncService: SyncService(), uid: user.uid),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _handleSignOut() async {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Deletes the unverified account so the user can sign up with a real email.
  Future<void> _handleChangeEmail() async {
    _timer?.cancel();
    _cooldownTimer?.cancel();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.delete();
      } else {
        await _authService.signOut();
      }
    } catch (_) {
      await _authService.signOut();
    }

    if (mounted) {
      // Keep LoginScreen under CreateAccount so "Log in" can pop safely.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p24,
                vertical: AppSpacing.p16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Email Icon
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.cardColor
                          : AppColors.containerColorGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages.passwordVerify,
                        width: 250,
                        height: 250,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.h32),

                  // Header Title
                  Text(
                    context.translate('verify_email_title'),
                    style: AppTextStyles.h1.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.h12),

                  // Subtitle Information
                  Text(
                    context.translate('verify_email_sent_subtitle'),
                    style: AppTextStyles.body.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.h16),

                  // Email Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p16,
                      vertical: AppSpacing.p12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.cardColor
                          : AppColors.containerColorGrey,
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : AppColors.dividerColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      email,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: theme.primaryColor
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.h24),

                  // Guidelines text
                  Text(
                    context.translate('verify_email_guideline'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.h40),

                  // Check Status Button
                  CustomButton(
                    text: _isReloading
                        ? context.translate('checking_status')
                        : context.translate('i_have_verified'),
                    onPressed: _isReloading ? () {} : _checkVerificationStatus,
                    backgroundColor: theme.primaryColor,
                  ),
                  const SizedBox(height: AppSpacing.h12),

                  CustomButton(
                    text: _resendCooldown > 0
                        ? '${context.translate('resend_in')}$_resendCooldown${context.translate('resend_seconds')}'
                        : context.translate('resend_verification_email'),
                    onPressed: (_resendCooldown > 0 || _isResending)
                        ? () {}
                        : _resendVerificationEmail,
                    backgroundColor: Colors.transparent,
                    textColor: theme.primaryColor,
                    showBorder: true,
                    borderColor: theme.primaryColor,
                  ),
                  const SizedBox(height: AppSpacing.h24),

                  if (widget.isFromSignup)
                    TextButton(
                      onPressed: _handleChangeEmail,
                      child: Text(
                        context.translate('change_email_address'),
                        style: AppTextStyles.bodyBold.copyWith(
                          color: theme.primaryColor
                        ),
                      ),
                    ),

                  // Cancel / Sign Out
                  TextButton.icon(
                    onPressed: _handleSignOut,
                    icon: Icon(
                      LucideIcons.logOut,
                      size: 16,
                      color: AppColors.activeRed,
                    ),
                    label: Text(
                      context.translate('cancel_and_sign_out'),
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.activeRed
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
