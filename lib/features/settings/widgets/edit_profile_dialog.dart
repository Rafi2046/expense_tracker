import 'dart:io';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:expense_tracker/features/settings/widgets/profile_dialog_header.dart';
import 'package:expense_tracker/features/settings/widgets/profile_photo_picker.dart';
import 'package:expense_tracker/features/settings/widgets/profile_name_field.dart';
import 'package:expense_tracker/features/settings/widgets/profile_save_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.translate('choose_option'),
                  style: AppTextStyles.h1.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(LucideIcons.image, size: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(context.translate('gallery'), style: AppTextStyles.label),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(LucideIcons.camera, size: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(context.translate('camera'), style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final user = FirebaseAuth.instance.currentUser;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final localFile = await File(image.path).copy(
          '${directory.path}/profile_${user?.uid}_$timestamp.jpg',
        );

        setState(() {
          _localImageFile = localFile;
          _photoUrlController.text = localFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('error_selecting_image', namedArgs: {'error': e.toString()})),
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

      await SharedPrefsHelper.setString(
        'local_profile_photo_${user.uid}',
        newPhotoUrl,
      );

      await user.updateDisplayName(newName);
      await user.updatePhotoURL(newPhotoUrl);
      await user.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('profile_updated')),
            backgroundColor: const Color(0xFF6A53A1),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('failed_update_profile', namedArgs: {'error': e.toString()})),
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
    final primaryColor =
        isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);
    final borderColor =
        isDark ? const Color(0xFF2D2D2D) : AppColors.dividerColor;

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
              ProfileDialogHeader(title: context.translate('edit_profile')),
              const SizedBox(height: 20),
              ProfilePhotoPicker(
                localImageFile: _localImageFile,
                photoUrl: _photoUrlController.text,
                isLoading: _isLoading,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: _pickProfileImage,
              ),
              const SizedBox(height: 24),
              ProfileNameField(controller: _nameController),
              const SizedBox(height: 16),
              CustomTextFieldWidget(
                label: context.translate('profile_photo_url'),
                hintText: context.translate('photo_url_hint'),
                controller: _photoUrlController,
              ),
              const SizedBox(height: 24),
              ProfileSaveButton(
                isLoading: _isLoading,
                isDark: isDark,
                primaryColor: primaryColor,
                borderColor: borderColor,
                onCancel: () => Navigator.pop(context),
                onSave: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
