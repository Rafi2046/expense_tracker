import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = const Color(0xFF6A53A1),
    Color iconBgColor = const Color(0xFFF3E8FF),
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Avatar Photo
        Center(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: Color(0xFF6A53A1),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.grey.shade100,
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
        const SizedBox(height: 20),

        // Name & Subtitle
        Center(
          child: Text(
            displayName,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (occupation.isNotEmpty) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              occupation,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6A53A1),
              ),
            ),
          ),
        ],
        const SizedBox(height: 36),

        // Info List Section
        Text(
          'DETAILS',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        _buildInfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: phone,
          iconColor: const Color(0xFF1E88E5),
          iconBgColor: const Color(0xFFE3F2FD),
        ),
        const Divider(height: 1, color: Color(0xFFF1F1F1)),

        _buildInfoRow(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: dob,
          iconColor: const Color(0xFFD81B60),
          iconBgColor: const Color(0xFFFCE4EC),
        ),
        const Divider(height: 1, color: Color(0xFFF1F1F1)),

        _buildInfoRow(
          icon: Icons.face_retouching_natural_rounded,
          label: 'Gender',
          value: gender,
          iconColor: const Color(0xFFFB8C00),
          iconBgColor: const Color(0xFFFFF3E0),
        ),
        const Divider(height: 1, color: Color(0xFFF1F1F1)),

        _buildInfoRow(
          icon: Icons.mail_outline_rounded,
          label: 'Email Address',
          value: user.email ?? '',
          iconColor: const Color(0xFF43A047),
          iconBgColor: const Color(0xFFE8F5E9),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: providerName == 'Google' ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              providerName,
              style: GoogleFonts.workSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: providerName == 'Google' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),

        // Action Trigger Button
        CustomButton(
          text: 'Edit Profile',
          onPressed: onEditTap,
          backgroundColor: const Color(0xFF0C4E3C),
          textColor: Colors.white,
        ),
      ],
    );
  }
}
