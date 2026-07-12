import 'package:flutter/material.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';

class ProfileBioField extends StatelessWidget {
  final TextEditingController controller;

  const ProfileBioField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      label: 'Bio',
      hintText: 'Tell us about yourself',
      controller: controller,
    );
  }
}
