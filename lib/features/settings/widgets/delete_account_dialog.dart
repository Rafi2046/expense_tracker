import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/settings/widgets/delete_account_reauth_body.dart';
import 'package:expense_tracker/features/settings/widgets/delete_account_warning_header.dart';
import 'package:expense_tracker/features/settings/widgets/delete_confirmation_body.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';



class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _deleteController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _canDelete = false;
  bool _isDeleting = false;
  bool _reauthMode = false;
  bool _isPasswordUser = false;
  bool _isAppleUser = false;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _deleteController.addListener(() {
      setState(() => _canDelete = _deleteController.text.trim().toUpperCase() == 'DELETE');
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
      _isAppleUser = user.providerData.any((p) => p.providerId == 'apple.com');
      _isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');
    }
  }

  @override
  void dispose() {
    _deleteController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _finishDeletion() async {
    await DatabaseHelper.instance.clearUserData();
    await DatabaseHelper.instance.checkDatabaseEmptyStatus();

    // Clear user-specific shared preferences keys
    await SharedPrefsHelper.remove(SharedPrefsHelper.activeProfileKey);
    await SharedPrefsHelper.remove(SharedPrefsHelper.onboardingCompleteKey);

    final authService = AuthService();
    try {
      await authService.signOut();
    } catch (_) {}

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      await _finishDeletion();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        setState(() {
          _isDeleting = false;
          _reauthMode = true;
        });
        return;
      }
      _handleError(e);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

      if (isGoogleUser) {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (_isAppleUser) {
        final appleIdCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (_isPasswordUser) {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('please_enter_password')),
                backgroundColor: AppColors.activeRed,
              ),
            );
          }
          setState(() => _isDeleting = false);
          return;
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        throw Exception('No supported sign-in method found');
      }

      await user.delete();
      await _finishDeletion();
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('something_wrong')),
          backgroundColor: AppColors.activeRed,
        ),
      );
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r16)),
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const DeleteAccountWarningHeader(),
              if (!_reauthMode)
                DeleteConfirmationBody(
                  controller: _deleteController,
                  canDelete: _canDelete,
                  isDeleting: _isDeleting,
                  onDelete: _deleteAccount,
                ),
              if (_reauthMode)
                DeleteAccountReauthBody(
                  isPasswordUser: _isPasswordUser,
                  isAppleUser: _isAppleUser,
                  isGoogleUser: _isGoogleUser,
                  isDeleting: _isDeleting,
                  passwordController: _passwordController,
                  onReauthenticate: _reauthenticateAndDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
