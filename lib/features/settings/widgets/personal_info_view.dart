import 'dart:io';
import 'package:expense_tracker/core/constants/app_images.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
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
                  style: GoogleFonts.workSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.workSans(
                    fontSize: 14.5,
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
        // Premium Profile Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F1F1), width: 1),
          ),
          child: Column(
            children: [
              // Avatar Photo with premium border and glow
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF6A53A1), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A53A1).withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    radius: 40,
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
              const SizedBox(height: 14),
              // Name
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              if (occupation.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  occupation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6A53A1),
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
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F1F1), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
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
                icon: gender == 'Male' ? Icons.male : Icons.female,
                label: 'Gender',
                value: gender,
                iconColor: gender == 'Male' ? const Color(0xFF1E88E5) : const Color(0xFFD81B60),
                iconBgColor: gender == 'Male' ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC),
              ),
              const Divider(height: 1, color: Color(0xFFF1F1F1)),
              _buildInfoRow(
                icon: Icons.mail_outline_rounded,
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
