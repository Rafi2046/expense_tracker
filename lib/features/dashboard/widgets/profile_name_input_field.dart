import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';

class ProfileNameInputField extends StatelessWidget {
  final TextEditingController controller;

  const ProfileNameInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      label: context.translate('your_name'),
      hintText: context.translate('enter_name'),
      controller: controller,
    );
  }
}
