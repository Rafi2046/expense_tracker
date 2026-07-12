import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfilePhotoSection extends StatelessWidget {
  final File? localImageFile;
  final String photoUrl;
  final VoidCallback onPickImage;

  const ProfilePhotoSection({
    super.key,
    required this.localImageFile,
    required this.photoUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;
    final primaryColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardBg,
                border: Border.all(color: primaryColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                backgroundImage: localImageFile != null
                    ? FileImage(localImageFile!) as ImageProvider
                    : (photoUrl.startsWith('http')
                        ? NetworkImage(photoUrl) as ImageProvider
                        : (photoUrl.isNotEmpty && File(photoUrl).existsSync()
                            ? FileImage(File(photoUrl)) as ImageProvider
                            : const AssetImage(AppImages.avatarImage))),
              ),
            ),
            GestureDetector(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
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
            ),
          ],
        ),
      ),
    );
  }
}
