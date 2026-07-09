import 'package:material_symbols_icons/symbols.dart';
import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PersonalInfoView extends StatelessWidget {
  final User user;
  final String photoUrl;
  final File? localImageFile;
  final String displayName;
  final String phone;
  final String dob;
  final String gender;
  final String occupation;
  final String providerName;
  final VoidCallback onEditTap;

  const PersonalInfoView({
    super.key,
    required this.user,
    required this.photoUrl,
    required this.localImageFile,
    required this.displayName,
    required this.phone,
    required this.dob,
    required this.gender,
    required this.occupation,
    required this.providerName,
    required this.onEditTap,
  });

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF6A53A1),
    Color iconBgColor = const Color(0xFFF3E8FF),
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedIconBg = isDark ? iconColor.withValues(alpha: 0.15) : iconBgColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: resolvedIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: value.isEmpty 
                      ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400) 
                      : Theme.of(context).colorScheme.onSurface,
                ),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);
    final primaryColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Premium Profile Header Card
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              // Avatar Photo with premium border and glow
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
                  padding: const EdgeInsets.all(2.0),
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
              const SizedBox(height: 14),
              // Name
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(color: theme.colorScheme.onSurface),
              ),
              if (occupation.isNotEmpty) ...[
                const SizedBox(height: 4),
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
        ),
        const SizedBox(height: 24),

        // Info List Section
        Text(
          'PERSONAL DETAILS',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              _buildInfoRow(
                context,
                icon: Symbols.phone,
                label: 'Phone Number',
                value: phone,
                iconColor: const Color(0xFF1E88E5),
                iconBgColor: const Color(0xFFE3F2FD),
              ),
              Divider(height: 1, color: borderColor),
              _buildInfoRow(
                context,
                icon: Symbols.cake,
                label: 'Date of Birth',
                value: dob,
                iconColor: const Color(0xFFD81B60),
                iconBgColor: const Color(0xFFFCE4EC),
              ),
              Divider(height: 1, color: borderColor),
              _buildInfoRow(
                context,
                icon: gender == 'Male' ? Symbols.male : Symbols.female,
                label: 'Gender',
                value: gender,
                iconColor: gender == 'Male' ? const Color(0xFF1E88E5) : const Color(0xFFD81B60),
                iconBgColor: gender == 'Male' ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC),
              ),
              Divider(height: 1, color: borderColor),
              _buildInfoRow(
                context,
                icon: Symbols.mail_outline_rounded,
                label: 'Email Address',
                value: user.email ?? '',
                iconColor: const Color(0xFF43A047),
                iconBgColor: const Color(0xFFE8F5E9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
