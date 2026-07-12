import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/settings/widgets/settings_text_field.dart';

class PhoneFieldSection extends StatelessWidget {
  final TextEditingController phoneController;

  const PhoneFieldSection({
    super.key,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTextField(
      label: 'Phone Number',
      hintText: 'Enter phone number',
      controller: phoneController,
      prefixIcon: LucideIcons.phoneCall,
      keyboardType: TextInputType.phone,
    );
  }
}
