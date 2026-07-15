import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/biometric_auth_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/login/utils/auth_handler.dart';
import 'package:expense_tracker/features/login/widgets/login_header.dart';
import 'package:expense_tracker/features/login/widgets/login_email_form.dart';
import 'package:expense_tracker/features/login/widgets/login_biometric_section.dart';
import 'package:expense_tracker/features/login/widgets/login_social_buttons.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/pages/forgot_password_screen.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/pages/create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool biometricMode;

  const LoginScreen({super.key, this.biometricMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, AuthHandler<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AnimationController? _biometricAnimController;
  Animation<double>? _biometricAnim;

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
        autoTriggerBiometric();
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

  @override
  Widget build(BuildContext context) {
    final biometricProvider = context.watch<BiometricAuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final biometricMode = widget.biometricMode;

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
                        biometricMode: biometricMode,
                        isDark: isDark,
                      ),

                      LoginEmailForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        biometricMode: biometricMode,
                        hasPasswordProvider: hasPasswordProvider,
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

                      if (biometricMode)
                        LoginBiometricSection(
                          biometricAnim: _biometricAnim!,
                          biometricProvider: biometricProvider,
                          biometricFailed: biometricFailed,
                          hasPasswordProvider: hasPasswordProvider,
                          isDark: isDark,
                          theme: theme,
                          onBiometricTap: handleBiometricTap,
                          onSwitchAccount: () =>
                              _handleSwitchAccount(context),
                        ),

                      if (!biometricMode || hasPasswordProvider)
                        CustomButton(
                          text: isLoading
                              ? (biometricMode
                                    ? context.translate('verifying')
                                    : context.translate('signing_in'))
                              : (biometricMode
                                    ? context.translate('sign_in_with_password')
                                    : context.translate('sign_in')),
                          onPressed: isLoading
                              ? () {}
                              : () => handleEmailLogin(
                                    biometricMode: biometricMode,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                        ),

                      if (!biometricMode)
                        LoginSocialButtons(
                          isDark: isDark,
                          isLoading: isLoading,
                          onGoogleSignIn: handleGoogleLogin,
                          onAppleSignIn: handleAppleLogin,
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

                      if (biometricMode && hasPasswordProvider) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _handleSwitchAccount(context),
                          child: Text(
                            context.translate('switch_account'),
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

  Future<void> _handleSwitchAccount(BuildContext context) async {
    final nav = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}
