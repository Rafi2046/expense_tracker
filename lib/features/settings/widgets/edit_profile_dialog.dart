import 'dart:io';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/session_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
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
      final savedPhoto = SharedPrefsHelper.getString(
        'local_profile_photo_${user.uid}',
      );
      final initialPhoto = (savedPhoto != null && savedPhoto.isNotEmpty)
          ? savedPhoto
          : (user.photoURL ?? '');
      _photoUrlController.text = initialPhoto;

      if (initialPhoto.isNotEmpty &&
          !initialPhoto.startsWith('http') &&
          File(initialPhoto).existsSync()) {
        _localImageFile = File(initialPhoto);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.translate('choose_option'),
                  style: AppTextStyles.h1.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.p16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(AppSpacing.r16),
                            ),
                            child: const Icon(LucideIcons.image, size: 32),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Text(context.translate('gallery'), style: AppTextStyles.label),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.p16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(AppSpacing.r16),
                            ),
                            child: const Icon(LucideIcons.camera, size: 32),
                          ),
                          const SizedBox(height: AppSpacing.s8),
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
      var photoUploadFailed = false;
      String? photoUploadError;
      String newPhotoUrl = _photoUrlController.text.trim();

      if (_localImageFile != null && _localImageFile!.existsSync()) {
        // Persist locally first so Settings / app bar update even if upload fails.
        await SharedPrefsHelper.setString(
          'local_profile_photo_${user.uid}',
          _localImageFile!.path,
        );
        newPhotoUrl = _localImageFile!.path;

        try {
          final cloudUrl =
              await AuthService().uploadProfileImage(_localImageFile!);
          // uploadProfileImage already writes Auth + Firestore + prefs.
          newPhotoUrl = cloudUrl;
        } catch (e) {
          debugPrint('Error uploading profile photo: $e');
          photoUploadFailed = true;
          photoUploadError = e.toString();
        }
      } else if (newPhotoUrl.isNotEmpty && newPhotoUrl.startsWith('http')) {
        await AuthService().persistProfilePhotoUrl(newPhotoUrl);
      }

      await user.updateDisplayName(newName);
      await user.reload();

      if (!mounted) return;
      await context.read<SessionProvider>().refresh();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            photoUploadFailed
                ? 'Photo upload failed: ${photoUploadError ?? "unknown"}'
                : context.translate('profile_updated'),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor:
              photoUploadFailed ? Colors.red : const Color(0xFF6A53A1),
          duration: Duration(seconds: photoUploadFailed ? 5 : 2),
        ),
      );
      Navigator.pop(context);
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
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileDialogHeader(title: context.translate('edit_profile')),
              const SizedBox(height: AppSpacing.s16),
              ProfilePhotoPicker(
                localImageFile: _localImageFile,
                photoUrl: _photoUrlController.text,
                isLoading: _isLoading,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: _pickProfileImage,
              ),
              const SizedBox(height: AppSpacing.s24),
              ProfileNameField(controller: _nameController),
              const SizedBox(height: AppSpacing.s16),
              CustomTextFieldWidget(
                label: context.translate('profile_photo_url'),
                hintText: context.translate('photo_url_hint'),
                controller: _photoUrlController,
              ),
              const SizedBox(height: AppSpacing.s24),
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
