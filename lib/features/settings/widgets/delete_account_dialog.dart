import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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

  @override
  void initState() {
    super.initState();
    _deleteController.addListener(() {
      setState(() => _canDelete = _deleteController.text.trim() == 'DELETE');
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
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

      if (_isPasswordUser) {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter your password'),
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
      } else if (isGoogleUser) {
        await user.reauthenticateWithProvider(GoogleAuthProvider());
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
          content: Text(
            'Failed to delete account: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.activeRed,
        ),
      );
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : AppColors.dividerColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red.withValues(alpha: 0.15)
                      : const Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.delete_forever_rounded,
                  color: AppColors.activeRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Delete Account',
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size22,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              if (!_reauthMode) ...[
                Text(
                  'Are you absolutely sure? This action cannot be undone.\n'
                  'It will permanently delete your account,\n'
                  'cloud backups, and all local data.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size14,
                    color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Type DELETE to confirm',
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.activeRed,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _deleteController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: AppFontSizes.size18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.activeRed,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    hintStyle: GoogleFonts.jetBrainsMono(
                      fontSize: AppFontSizes.size18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      letterSpacing: 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _canDelete ? AppColors.activeRed : borderColor,
                        width: 2,
                      ),
                    ),
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade50,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _isDeleting ? 'Deleting...' : 'Delete',
                    onPressed: _canDelete && !_isDeleting
                        ? () => _deleteAccount()
                        : () {},
                    backgroundColor: _canDelete
                        ? AppColors.activeRed
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],

              if (_reauthMode) ...[
                Text(
                  'Please verify your identity\nto delete your account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size14,
                    color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                if (_isPasswordUser) ...[
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size15,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size15,
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.activeRed, width: 2),
                      ),
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade50,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isDeleting ? 'Deleting...' : 'Reauthenticate & Delete',
                      onPressed: !_isDeleting
                          ? () => _reauthenticateAndDelete()
                          : () {},
                      backgroundColor: AppColors.activeRed,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],

                if (!_isPasswordUser) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isDeleting ? 'Deleting...' : 'Continue with Google',
                      onPressed: !_isDeleting
                          ? () => _reauthenticateAndDelete()
                          : () {},
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      showBorder: true,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
