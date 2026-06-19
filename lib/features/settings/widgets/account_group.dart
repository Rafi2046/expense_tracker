import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:flutter/material.dart';

class AccountGroup extends StatelessWidget {
  final Function(String) onSnackBar;

  const AccountGroup({super.key, required this.onSnackBar});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: 'Account',
      children: [
        SettingsOptionRow(
          icon: Icons.person_rounded,
          iconBgColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1E88E5),
          title: 'Personal Information',
          onTap: () => onSnackBar('Personal Information clicked'),
        ),
        SettingsOptionRow(
          icon: Icons.lock_rounded,
          iconBgColor: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFFB8C00),
          title: 'Security & Privacy',
          onTap: () => onSnackBar('Security & Privacy clicked'),
        ),
        SettingsOptionRow(
          icon: Icons.notifications_rounded,
          iconBgColor: const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFD81B60),
          title: 'Notifications',
          onTap: () => onSnackBar('Notifications clicked'),
        ),
      ],
    );
  }
}
