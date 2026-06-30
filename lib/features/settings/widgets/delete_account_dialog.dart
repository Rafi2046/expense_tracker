import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/features/login/pages/login_screen.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _canDelete = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _canDelete = _controller.text.trim() == 'DELETE');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      await DatabaseHelper.instance.clearUserData();
      await DatabaseHelper.instance.checkDatabaseEmptyStatus();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.delete();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.activeRed,
                  duration: const Duration(seconds: 3),
                  content: const Text(
                    'Please log in again to verify your identity before deleting your account.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
              await Future.delayed(const Duration(seconds: 2));
              await FirebaseAuth.instance.signOut();
            }
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
            return;
          }
          rethrow;
        }
      }

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
    } catch (e) {
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
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Are you absolutely sure? This action cannot be undone.\n'
              'It will permanently delete your account,\n'
              'cloud backups, and all local data.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 13.5,
                color: isDark ? Colors.grey.shade400 : AppColors.loginSubTitle,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Type DELETE to confirm',
              style: GoogleFonts.workSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.activeRed,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.activeRed,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
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

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: _isDeleting ? () {} : () => Navigator.pop(context),
                    backgroundColor: isDark ? theme.cardColor : Colors.white,
                    textColor: theme.colorScheme.onSurface,
                    showBorder: true,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: CustomButton(
                    text: _isDeleting ? 'Deleting...' : 'Delete',
                    onPressed: _canDelete && !_isDeleting ? () => _deleteAccount() : () {},
                    backgroundColor: _canDelete
                        ? AppColors.activeRed
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
