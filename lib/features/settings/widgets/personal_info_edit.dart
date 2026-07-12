import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/widgets/profile_photo_section.dart';
import 'package:expense_tracker/features/settings/widgets/name_fields_section.dart';
import 'package:expense_tracker/features/settings/widgets/phone_field_section.dart';
import 'package:expense_tracker/features/settings/widgets/date_of_birth_section.dart';
import 'package:expense_tracker/features/settings/widgets/gender_selector_section.dart';
import 'package:expense_tracker/features/settings/widgets/occupation_field_section.dart';
import 'package:expense_tracker/features/settings/widgets/email_display_section.dart';
import 'package:expense_tracker/features/settings/widgets/action_buttons_section.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfilePhotoSection(
          localImageFile: localImageFile,
          photoUrl: photoUrl,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: 24),
        NameFieldsSection(
          firstNameController: firstNameController,
          lastNameController: lastNameController,
        ),
        const SizedBox(height: 20),
        PhoneFieldSection(phoneController: phoneController),
        const SizedBox(height: 20),
        DateOfBirthSection(
          dobController: dobController,
          onSelectDate: onSelectDate,
        ),
        const SizedBox(height: 20),
        GenderSelectorSection(
          selectedGender: selectedGender,
          onGenderChanged: onGenderChanged,
        ),
        const SizedBox(height: 20),
        OccupationFieldSection(occupationController: occupationController),
        const SizedBox(height: 20),
        EmailDisplaySection(userEmail: userEmail),
        const SizedBox(height: 24),
        ActionButtonsSection(
          isLoading: isLoading,
          onSave: onSave,
          onCancel: onCancel,
        ),
      ],
    );
  }
}
