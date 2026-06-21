import 'dart:io';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInfoEdit extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController occupationController;
  final String selectedGender;
  final Function(String) onGenderChanged;
  final File? localImageFile;
  final String photoUrl;
  final bool isLoading;
  final String providerName;
  final String userEmail;
  final VoidCallback onPickImage;
  final VoidCallback onSelectDate;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const PersonalInfoEdit({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.dobController,
    required this.occupationController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.localImageFile,
    required this.photoUrl,
    required this.isLoading,
    required this.providerName,
    required this.userEmail,
    required this.onPickImage,
    required this.onSelectDate,
    required this.onSave,
    required this.onCancel,
  });

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.workSans(fontSize: 14.5, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.workSans(fontSize: 14, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Circular Avatar with edit indicator
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
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
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6A53A1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // First Name & Last Name (Side by Side)
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'First Name',
                hintText: 'First Name',
                controller: firstNameController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Last Name',
                hintText: 'Last Name',
                controller: lastNameController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Phone Input
        _buildTextField(
          label: 'Phone Number',
          hintText: 'Enter phone number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),

        // Date of Birth Input (Picks Date)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth',
              style: GoogleFonts.workSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: dobController,
                readOnly: true,
                onTap: onSelectDate,
                style: GoogleFonts.workSans(fontSize: 14.5, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'DD/MM/YYYY',
                  hintStyle: GoogleFonts.workSans(fontSize: 14, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Gender Choice Chips
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: GoogleFonts.workSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Male', 'Female', 'Other'].map((gender) {
                final isSelected = selectedGender == gender;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: Text(
                      gender,
                      style: GoogleFonts.workSans(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0C4E3C),
                    backgroundColor: const Color(0xFFF5F6F8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide.none,
                    onSelected: (selected) {
                      if (selected) {
                        onGenderChanged(gender);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Occupation Input
        _buildTextField(
          label: 'Occupation',
          hintText: 'e.g. Software Engineer',
          controller: occupationController,
        ),
        const SizedBox(height: 20),

        // Email Address (Read-Only)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.loginLabelColor,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userEmail,
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: providerName == 'Google' ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          providerName == 'Google' ? Icons.g_mobiledata : Icons.email_outlined,
                          color: providerName == 'Google' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          providerName,
                          style: GoogleFonts.workSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: providerName == 'Google' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Cancel / Save Buttons Row
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                onPressed: isLoading ? () {} : onCancel,
                backgroundColor: Colors.white,
                textColor: const Color(0xFF31394D),
                showBorder: true,
                borderColor: AppColors.dividerColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: isLoading ? 'Saving...' : 'Save',
                onPressed: isLoading ? () {} : onSave,
                backgroundColor: const Color(0xFF0C4E3C),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
