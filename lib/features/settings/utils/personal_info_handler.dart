import 'dart:io';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/services/auth_services.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/settings/widgets/image_picker_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


mixin PersonalInfoHandler<T extends StatefulWidget> on State<T> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final occupationController = TextEditingController();

  File? localImageFile;
  String photoUrl = '';
  bool isLoading = false;
  bool isEditing = false;
  late User user;
  String providerName = 'Email';
  String selectedGender = 'Male';
  DateTime? selectedDate;

  void loadUserInfo() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      user = currentUser;

      final displayName = user.displayName ?? '';
      final nameParts = displayName.split(' ');
      if (nameParts.isNotEmpty) {
        firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          lastNameController.text = nameParts.sublist(1).join(' ');
        } else {
          lastNameController.clear();
        }
      }

      photoUrl = user.photoURL ?? '';

      phoneController.text = SharedPrefsHelper.getString('local_phone_number_${user.uid}') ?? '';
      selectedGender = SharedPrefsHelper.getString('local_gender_${user.uid}') ?? 'Male';
      dobController.text = SharedPrefsHelper.getString('local_dob_${user.uid}') ?? '';
      occupationController.text = SharedPrefsHelper.getString('local_occupation_${user.uid}') ?? '';

      final providers = user.providerData.map((info) => info.providerId).toList();
      if (providers.contains('google.com')) {
        providerName = 'Google';
      }

      if (photoUrl.isNotEmpty && !photoUrl.startsWith('http') && File(photoUrl).existsSync()) {
        localImageFile = File(photoUrl);
      } else {
        localImageFile = null;
      }
    }
  }

  Future<void> pickImage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (_) => const ImagePickerSheet(),
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
        final localFile = await File(image.path).copy(
          '${directory.path}/profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (!mounted) return;
        setState(() {
          localImageFile = localFile;
          photoUrl = localFile.path;
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.translate('error_selecting_image', namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF8E75C8),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E2E),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF6A53A1),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> saveChanges() async {
    final name = "${firstNameController.text} ${lastNameController.text}".trim();

    if (firstNameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('first_name_required')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().updatePersonalInfo(displayName: name);

      String finalPhotoUrl = photoUrl;
      if (localImageFile != null && localImageFile!.existsSync()) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_photos')
              .child('${user.uid}.jpg');
          final uploadTask = storageRef.putFile(localImageFile!);
          final snapshot = await uploadTask;
          finalPhotoUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          debugPrint('Error uploading profile photo: $e');
          // Never write a local file path into Auth photoURL — other devices
          // (and reinstalls) cannot load it.
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.translate('failed_save_changes', namedArgs: {
                    'error': 'Profile photo upload failed. Check Storage rules.',
                  }),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          finalPhotoUrl = user.photoURL ?? '';
        }
      }

      // Only persist https (or empty). Skip broken local paths.
      if (finalPhotoUrl.isNotEmpty && !finalPhotoUrl.startsWith('http')) {
        finalPhotoUrl = user.photoURL ?? '';
      }

      if (finalPhotoUrl != (user.photoURL ?? '') &&
          (finalPhotoUrl.isEmpty || finalPhotoUrl.startsWith('http'))) {
        await user.updatePhotoURL(finalPhotoUrl.isEmpty ? null : finalPhotoUrl);
        await user.reload();
        if (finalPhotoUrl.isNotEmpty) {
          await SharedPrefsHelper.setString(
            'local_profile_photo_${user.uid}',
            finalPhotoUrl,
          );
        }
        photoUrl = finalPhotoUrl;
      }

      await SharedPrefsHelper.setString('local_phone_number_${user.uid}', phoneController.text.trim());
      await SharedPrefsHelper.setString('local_gender_${user.uid}', selectedGender);
      await SharedPrefsHelper.setString('local_dob_${user.uid}', dobController.text.trim());
      await SharedPrefsHelper.setString('local_occupation_${user.uid}', occupationController.text.trim());

      loadUserInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.translate('profile_updated'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF6A53A1),
          ),
        );
        setState(() => isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('failed_save_changes', namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void cancelEditing() {
    loadUserInfo();
    setState(() => isEditing = false);
  }

  void disposeControllers() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    occupationController.dispose();
  }
}
