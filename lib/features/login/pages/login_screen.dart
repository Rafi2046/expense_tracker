import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/features/bottom_navigation/pages/bottom_nav_screen.dart';
import 'package:expense_tracker/features/login/pages/forgot_password_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool biometricMode;

  const LoginScreen({super.key, this.biometricMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
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
      final success = await context.read<BiometricAuthProvider>().authenticate();
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
      final success = await context.read<BiometricAuthProvider>().authenticate();
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

    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null && mounted) {
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
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
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
  }

  Future<void> _handleSwitchAccount() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biometricProvider = context.watch<BiometricAuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: Column(
                    spacing: AppSpacing.s16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(AppImages.splashLogo, height: 64, width: 64),

                      Text(
                        widget.biometricMode ? 'Welcome Back' : 'Welcome Back',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginTitle,
                      ),

                      Text(
                        widget.biometricMode
                            ? 'Authenticate to continue your financial journey'
                            : 'Sign in to continue your financial journey',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.loginSubTitle,
                      ),

                      CustomTextFieldWidget(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'you@example.com',
                      ),

                      if (!widget.biometricMode || _hasPasswordProvider)
                        CustomTextFieldWidget(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: '••••••••',
                          obscureText: true,
                          trailingLabelWidget: widget.biometricMode
                              ? null
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTextStyles.textFieldLabelPassword,
                                  ),
                                ),
                        ),

                      if (widget.biometricMode) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: _handleBiometricTap,
                            child: AnimatedBuilder(
                              animation: _biometricAnim!,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _biometricAnim!.value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.primaryColor.withValues(alpha: 0.1),
                                    ),
                                    child: Icon(
                                      biometricProvider.icon,
                                      size: 40,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _biometricFailed ? 'Authentication failed. Tap to retry.' : 'Tap to unlock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: _biometricFailed
                                ? const Color(0xFFE53935)
                                : theme.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                        if (_hasPasswordProvider) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Or enter your password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],

                      if (widget.biometricMode && !_hasPasswordProvider)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: _handleSwitchAccount,
                            child: Text(
                              'Switch Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      if (!widget.biometricMode || _hasPasswordProvider)
                        CustomButton(
                          text: _isLoading
                              ? (widget.biometricMode ? 'Verifying...' : 'Signing In...')
                              : (widget.biometricMode ? 'Sign In with Password' : 'Sign In'),
                          onPressed: _isLoading ? () {} : _handleEmailLogin,
                        ),

                      if (!widget.biometricMode) ...[
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.dividerColor, thickness: 2)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
                              child: const Text('or', style: TextStyle(color: AppColors.dividerOrColor)),
                            ),
                            const Expanded(child: Divider(color: AppColors.dividerColor, thickness: 2)),
                          ],
                        ),

                        CustomButton(
                          leading: Image.asset(AppImages.googleLogo),
                          showBorder: true,
                          borderColor: AppColors.borderColor,
                          text: 'Continue with Google',
                          textColor: AppColors.googleTextColor,
                          fontFamily: GoogleFonts.inter().fontFamily,
                          onPressed: _isLoading ? () {} : _handleGoogleLogin,
                          backgroundColor: AppColors.white,
                        ),

                        CustomButton(
                          leading: Image.asset(AppImages.facebookLogo),
                          showBorder: true,
                          borderColor: AppColors.borderColor,
                          text: 'Continue with Facebook',
                          textColor: AppColors.black,
                          fontFamily: GoogleFonts.inter().fontFamily,
                          onPressed: () {},
                          backgroundColor: AppColors.white,
                        ),

                        CustomButton(
                          leading: Transform.scale(
                            scale: 1.4,
                            child: Image.asset(AppImages.appleLogo),
                          ),
                          showBorder: true,
                          borderColor: AppColors.borderColor,
                          text: 'Continue with Apple',
                          textColor: AppColors.googleTextColor,
                          fontFamily: GoogleFonts.inter().fontFamily,
                          onPressed: () {},
                          backgroundColor: AppColors.white,
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: AppTextStyles.accountText),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateAccountScreen(),
                                  ),
                                );
                              },
                              child: Text('Sign Up', style: AppTextStyles.signUpText),
                            ),
                          ],
                        ),
                      ],

                      if (widget.biometricMode && _hasPasswordProvider) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _handleSwitchAccount,
                          child: Text(
                            'Switch Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
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
