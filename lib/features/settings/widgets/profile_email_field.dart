import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/login/widgets/custom_text_field_widget.dart';

class ProfileEmailField extends StatelessWidget {
  final TextEditingController controller;

  const ProfileEmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextFieldWidget(
      label: context.translate('email'),
      hintText: context.translate('enter_your_email'),
      controller: controller,
    );
  }
}
