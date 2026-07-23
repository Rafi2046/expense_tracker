import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class ProfileHeaderCard extends StatelessWidget {
  final String displayName;
  final String occupation;
  final File? localImageFile;
  final String photoUrl;

  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.occupation,
    required this.localImageFile,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);
    final primaryColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              border: Border.all(color: primaryColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.p4),
              child: CircleAvatar(
                radius: 40,
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
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(color: theme.colorScheme.onSurface),
          ),
          if (occupation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              occupation,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
