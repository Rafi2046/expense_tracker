import 'package:flutter/material.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';

class ProfileNameField extends StatelessWidget {
  final TextEditingController controller;

  const ProfileNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      label: 'Display Name',
      hintText: 'Enter your name',
      controller: controller,
    );
  }
}
