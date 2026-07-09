import 'package:material_symbols_icons/symbols.dart';
import 'dart:io';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  File? _localImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _photoUrlController.text = user.photoURL ?? '';
      
      // If photoURL is a local file path that exists, show it in the preview
      if (user.photoURL != null &&
          !user.photoURL!.startsWith('http') &&
          File(user.photoURL!).existsSync()) {
        _localImageFile = File(user.photoURL!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Copy the image permanently to the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final user = FirebaseAuth.instance.currentUser;
        final localFile = await File(image.path).copy('${directory.path}/profile_${user?.uid}.jpg');

        setState(() {
          _localImageFile = localFile;
          _photoUrlController.text = localFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final newName = _nameController.text.trim();
      final newPhotoUrl = _photoUrlController.text.trim();

      await user.updateDisplayName(newName);
      await user.updatePhotoURL(newPhotoUrl);
      await user.reload();

      // Backup local path in SharedPreferences for this specific user
      await SharedPrefsHelper.setString('local_profile_photo_${user.uid}', newPhotoUrl);

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);
    final borderColor = isDark ? const Color(0xFF2D2D2D) : AppColors.dividerColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: theme.cardColor,
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
                  fontSize: AppFontSizes.size20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Avatar Photo Picker
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _pickProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                          backgroundImage: _localImageFile != null
                              ? FileImage(_localImageFile!) as ImageProvider
                              : (_photoUrlController.text.startsWith('http')
                                  ? NetworkImage(_photoUrlController.text) as ImageProvider
                                  : (_photoUrlController.text.isNotEmpty && File(_photoUrlController.text).existsSync()
                                      ? FileImage(File(_photoUrlController.text)) as ImageProvider
                                      : const AssetImage(AppImages.avatarImage))),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Symbols.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name Input
              CustomTextFieldWidget(
                label: 'Display Name',
                hintText: 'Enter your name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              // Photo URL Input (Still available for reference/fallback)
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
                      backgroundColor: isDark ? theme.cardColor : Colors.white,
                      textColor: theme.colorScheme.onSurface,
                      showBorder: true,
                      borderColor: borderColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save Button
                  Expanded(
                    child: CustomButton(
                      text: _isLoading ? 'Saving...' : 'Save',
                      onPressed: _isLoading ? () {} : _saveProfile,
                      backgroundColor: primaryColor,
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
