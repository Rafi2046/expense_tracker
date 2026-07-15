import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/settings/widgets/settings_text_field.dart';

class NameFieldsSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const NameFieldsSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SettingsTextField(
            label: context.translate('first_name'),
            hintText: context.translate('first_name'),
            controller: firstNameController,
            prefixIcon: LucideIcons.user,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SettingsTextField(
            label: context.translate('last_name'),
            hintText: context.translate('last_name'),
            controller: lastNameController,
            prefixIcon: LucideIcons.user,
          ),
        ),
      ],
    );
  }
}
