import 'package:material_symbols_icons/symbols.dart';
import 'dart:io';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/features/login/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: AppFontSizes.size13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade400 : Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.workSans(fontSize: AppFontSizes.size15, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? theme.cardColor : const Color(0xFFF5F6F8),
            prefixIcon: Icon(
              prefixIcon,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 18,
            ),
            hintText: hintText,
            hintStyle: GoogleFonts.workSans(fontSize: AppFontSizes.size14, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);
    final primaryColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);
    final inputBg = isDark ? theme.cardColor : const Color(0xFFF5F6F8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Premium Profile Header Card for editing
        Container(
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
                      Symbols.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // First Name & Last Name (Side by Side)
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                label: 'First Name',
                hintText: 'First Name',
                controller: firstNameController,
                prefixIcon: Symbols.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                context,
                label: 'Last Name',
                hintText: 'Last Name',
                controller: lastNameController,
                prefixIcon: Symbols.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Phone Input
        _buildTextField(
          context,
          label: 'Phone Number',
          hintText: 'Enter phone number',
          controller: phoneController,
          prefixIcon: Symbols.phone,
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
                fontSize: AppFontSizes.size13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: dobController,
              readOnly: true,
              onTap: onSelectDate,
              style: GoogleFonts.workSans(fontSize: AppFontSizes.size15, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputBg,
                prefixIcon: Icon(
                  Symbols.cake,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  size: 18,
                ),
                hintText: 'DD/MM/YYYY',
                hintStyle: GoogleFonts.workSans(fontSize: AppFontSizes.size14, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
                suffixIcon: Icon(
                  Symbols.calendar_today_rounded,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Gender Custom Selector (50/50 Split)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gender',
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Male', 'Female'].map((gender) {
                final isSelected = selectedGender == gender;
                final genderIcon = gender == 'Male' ? Symbols.male_rounded : Symbols.female_rounded;
                final activeColor = gender == 'Male' ? const Color(0xFF1E88E5) : const Color(0xFFD81B60);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onGenderChanged(gender),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: gender == 'Male' ? 6.0 : 0.0,
                        left: gender == 'Female' ? 6.0 : 0.0,
                      ),
                      height: 46,
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? activeColor : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 16,
                            child: Icon(
                              genderIcon,
                              color: isSelected ? Colors.white : activeColor,
                              size: 18,
                            ),
                          ),
                          Text(
                            gender,
                            style: GoogleFonts.workSans(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSizes.size14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Occupation Input
        _buildTextField(
          context,
          label: 'Occupation',
          hintText: 'e.g. Software Engineer',
          controller: occupationController,
          prefixIcon: Symbols.work_outline_rounded,
        ),
        const SizedBox(height: 20),

        // Email Address (Read-Only)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: AppFontSizes.size14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : AppColors.loginLabelColor,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size15,
                        color: isDark ? Colors.grey.shade400 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
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
                backgroundColor: isDark ? theme.cardColor : Colors.white,
                textColor: theme.colorScheme.onSurface,
                showBorder: true,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: isLoading ? 'Saving...' : 'Save',
                onPressed: isLoading ? () {} : onSave,
                backgroundColor: isDark ? const Color(0xFF0C4E3C) : const Color(0xFF0C4E3C),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
