import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/utils/profile_photo_resolver.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class ProfilePhotoPicker extends StatelessWidget {
  final File? localImageFile;
  final String photoUrl;
  final bool isLoading;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback? onTap;

  const ProfilePhotoPicker({
    super.key,
    this.localImageFile,
    required this.photoUrl,
    required this.isLoading,
    required this.isDark,
    required this.primaryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.p4),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                backgroundImage: _resolveImage(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.p8),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.camera,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _resolveImage() {
    if (localImageFile != null) {
      return FileImage(localImageFile!);
    }
    return ProfilePhotoResolver.provider(photoUrl) ??
        const AssetImage(AppImages.avatarImage);
  }
}
