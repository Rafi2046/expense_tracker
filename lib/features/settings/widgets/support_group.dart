import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/settings/widgets/logout_dialog.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:flutter/material.dart';

class SupportGroup extends StatelessWidget {
  final Function(String) onSnackBar;

  const SupportGroup({super.key, required this.onSnackBar});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: 'Support',
      children: [
        SettingsOptionRow(
          icon: Icons.help_rounded,
          iconBgColor: const Color(0xFFECEFF1),
          iconColor: const Color(0xFF546E7A),
          title: 'Help Center',
          onTap: () => onSnackBar('Help Center clicked'),
        ),
        SettingsOptionRow(
          icon: Icons.shield_rounded,
          iconBgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF43A047),
          title: 'Privacy Policy',
          onTap: () => onSnackBar('Privacy Policy clicked'),
        ),
        SettingsOptionRow(
          icon: Icons.logout_rounded,
          iconBgColor: const Color(0xFFFFF1F0),
          iconColor: const Color(0xFFE53935),
          title: 'Logout',
          color: AppColors.activeRed,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LogoutDialog(),
            );
          },
        ),
      ],
    );
  }
}
