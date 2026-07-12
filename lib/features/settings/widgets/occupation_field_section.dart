import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/settings/widgets/settings_text_field.dart';

class OccupationFieldSection extends StatelessWidget {
  final TextEditingController occupationController;

  const OccupationFieldSection({
    super.key,
    required this.occupationController,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTextField(
      label: 'Occupation',
      hintText: 'e.g. Software Engineer',
      controller: occupationController,
      prefixIcon: LucideIcons.briefcase,
    );
  }
}
