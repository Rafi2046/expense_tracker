import 'dart:io';
import 'package:expense_tracker/features/settings/widgets/profile_header_card.dart';
import 'package:expense_tracker/features/settings/widgets/personal_info_details_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHeaderCard(
          displayName: displayName,
          occupation: occupation,
          localImageFile: localImageFile,
          photoUrl: photoUrl,
        ),
        const SizedBox(height: AppSpacing.s24),
        PersonalInfoDetailsCard(
          phone: phone,
          dob: dob,
          gender: gender,
          email: user.email ?? '',
        ),
      ],
    );
  }
}
