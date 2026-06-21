import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InlinePasswordForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const InlinePasswordForm({super.key, required this.onSuccess});

  @override
  State<InlinePasswordForm> createState() => _InlinePasswordFormState();
}

class _InlinePasswordFormState extends State<InlinePasswordForm> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all password fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters long.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Color(0xFF6A53A1),
          ),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.workSans(fontSize: 14.5, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.workSans(fontSize: 14, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          label: 'Current Password',
          hintText: 'Enter current password',
          obscureText: _obscureCurrentPassword,
          controller: _currentPasswordController,
          onToggleObscure: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'New Password',
          hintText: 'Min. 6 characters',
          obscureText: _obscureNewPassword,
          controller: _newPasswordController,
          onToggleObscure: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirm New Password',
          hintText: 'Re-enter new password',
          obscureText: _obscureConfirmPassword,
          controller: _confirmPasswordController,
          onToggleObscure: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0C4E3C),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Update Password',
                  style: GoogleFonts.workSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
