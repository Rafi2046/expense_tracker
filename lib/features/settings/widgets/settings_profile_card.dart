import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback? onEditTap;

  const SettingsProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circle Avatar with subtle ring
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: (photoUrl != null && photoUrl!.startsWith('http'))
                  ? NetworkImage(photoUrl!) as ImageProvider
                  : (photoUrl != null && photoUrl!.isNotEmpty && File(photoUrl!).existsSync()
                      ? FileImage(File(photoUrl!)) as ImageProvider
                      : const AssetImage(AppImages.avatarImage)),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Edit Button with translucent circle overlay
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: IconButton(
              onPressed: onEditTap,
              icon: const Icon(
                LucideIcons.edit,
                color: Colors.white,
                size: 16,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 16,
            ),
          ),
        ],
      ),
    );
  }
}
