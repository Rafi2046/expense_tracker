import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _photoUrlController.text = user.photoURL ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await user.updateDisplayName(_nameController.text.trim());
      await user.updatePhotoURL(_photoUrlController.text.trim());
      await user.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF6A53A1),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Edit Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              const SizedBox(height: 20),

              // Name Input
              CustomTextFieldWidget(
                label: 'Display Name',
                hintText: 'Enter your name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              // Photo URL Input
              CustomTextFieldWidget(
                label: 'Profile Photo URL',
                hintText: 'https://example.com/avatar.png',
                controller: _photoUrlController,
              ),
              const SizedBox(height: 24),

              // Actions Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: _isLoading ? () {} : () => Navigator.pop(context),
                      backgroundColor: Colors.white,
                      textColor: const Color(0xFF31394D),
                      showBorder: true,
                      borderColor: AppColors.dividerColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save Button
                  Expanded(
                    child: CustomButton(
                      text: _isLoading ? 'Saving...' : 'Save',
                      onPressed: _isLoading ? () {} : _saveProfile,
                      backgroundColor: const Color(0xFF6A53A1),
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
