import 'package:expense_tracker/features/settings/pages/help_center_screen.dart';
import 'package:expense_tracker/features/settings/pages/privacy_policy_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupportGroup extends StatelessWidget {
  final Function(String) onSnackBar;

  const SupportGroup({super.key, required this.onSnackBar});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: context.translate('support'),
      children: [
        SettingsOptionRow(
          icon: LucideIcons.helpCircle,
          title: context.translate('help_center'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpCenterScreen(),
            ),
          ),
        ),
        SettingsOptionRow(
          icon: LucideIcons.shield,
          title: context.translate('privacy_policy'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacyPolicyScreen(),
            ),
          ),
        ),

      ],
    );
  }
}
