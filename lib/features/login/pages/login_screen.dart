import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/services/sync_service.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/login/pages/forgot_password_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/sync_loading_overlay.dart';
import 'package:expense_tracker/features/login/widgets/login_header.dart';
import 'package:expense_tracker/features/login/widgets/login_email_form.dart';
import 'package:expense_tracker/features/login/widgets/login_biometric_section.dart';
import 'package:expense_tracker/features/login/widgets/login_social_buttons.dart';
import 'package:expense_tracker/features/onboarding/pages/onboarding_screen.dart';
import 'create_account_screen.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class LoginScreen extends StatefulWidget {
  final bool biometricMode;

  const LoginScreen({super.key, this.biometricMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _biometricFailed = false;

  AnimationController? _biometricAnimController;
  Animation<double>? _biometricAnim;

  bool get _hasPasswordProvider {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  @override
  void initState() {
    super.initState();

    if (widget.biometricMode) {
      _biometricAnimController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat(reverse: true);
      _biometricAnim = Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
          parent: _biometricAnimController!,
          curve: Curves.easeInOutSine,
        ),
      );

      _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BiometricAuthProvider>().detectBiometrics();
        _autoTriggerBiometric();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _biometricAnimController?.dispose();
    super.dispose();
  }

  Future<void> _autoTriggerBiometric() async {
    HapticFeedback.lightImpact();
    try {
      final success = await context
          .read<BiometricAuthProvider>()
          .authenticate();
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        );
      } else {
        HapticFeedback.heavyImpact();
        setState(() => _biometricFailed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _biometricFailed = true);
    }
  }

  Future<void> _handleBiometricTap() async {
    HapticFeedback.lightImpact();
    try {
      final success = await context
          .read<BiometricAuthProvider>()
          .authenticate();
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        );
      } else {
        HapticFeedback.heavyImpact();
        setState(() => _biometricFailed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _biometricFailed = true);
    }
  }

  Future<void> _handleEmailLogin() async {
    if (widget.biometricMode) {
      if (_passwordController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser!;
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: _passwordController.text.trim(),
          ),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (cred != null && mounted) {
        _navigateAfterAuth(cred);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final cred = await _authService.signInWithGoogle();

      if (cred != null && mounted) {
        _navigateAfterAuth(cred);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);

    try {
      final cred = await _authService.signInWithApple();

      if (cred != null && mounted) {
        _navigateAfterAuth(cred);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSwitchAccount() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _navigateAfterAuth(UserCredential cred) async {
    final isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (isNewUser || uid == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final syncService = SyncService();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SyncLoadingOverlay(syncService: syncService, uid: uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biometricProvider = context.watch<BiometricAuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    spacing: AppSpacing.s16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoginHeader(
                        biometricMode: widget.biometricMode,
                        isDark: isDark,
                      ),

                      LoginEmailForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        biometricMode: widget.biometricMode,
                        hasPasswordProvider: _hasPasswordProvider,
                        isDark: isDark,
                        onForgotPassword: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                      ),

                      if (widget.biometricMode)
                        LoginBiometricSection(
                          biometricAnim: _biometricAnim!,
                          biometricProvider: biometricProvider,
                          biometricFailed: _biometricFailed,
                          hasPasswordProvider: _hasPasswordProvider,
                          isDark: isDark,
                          theme: theme,
                          onBiometricTap: _handleBiometricTap,
                          onSwitchAccount: _handleSwitchAccount,
                        ),

                      if (!widget.biometricMode || _hasPasswordProvider)
                        CustomButton(
                          text: _isLoading
                              ? (widget.biometricMode
                                    ? 'Verifying...'
                                    : 'Signing In...')
                              : (widget.biometricMode
                                    ? 'Sign In with Password'
                                    : 'Sign In'),
                          onPressed: _isLoading ? () {} : _handleEmailLogin,
                        ),

                      if (!widget.biometricMode)
                        LoginSocialButtons(
                          isDark: isDark,
                          isLoading: _isLoading,
                          onGoogleSignIn: _handleGoogleLogin,
                          onAppleSignIn: _handleAppleLogin,
                          onSignUp: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAccountScreen(),
                              ),
                            );
                          },
                        ),

                      if (widget.biometricMode && _hasPasswordProvider) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _handleSwitchAccount,
                          child: Text(
                            'Switch Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFontSizes.size14,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
