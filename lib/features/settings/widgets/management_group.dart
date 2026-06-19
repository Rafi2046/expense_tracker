import 'package:expense_tracker/features/settings/pages/manage_categories_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:flutter/material.dart';

class ManagementGroup extends StatelessWidget {
  final VoidCallback onShowReportSelector;

  const ManagementGroup({super.key, required this.onShowReportSelector});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: 'Management',
      children: [
        SettingsOptionRow(
          icon: Icons.category_rounded,
          iconBgColor: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF8E24AA),
          title: 'Manage Categories',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageCategoriesScreen(),
              ),
            );
          },
        ),
        SettingsOptionRow(
          icon: Icons.bar_chart_rounded,
          iconBgColor: const Color(0xFFE8F8F5),
          iconColor: const Color(0xFF16A085),
          title: 'View Reports',
          onTap: onShowReportSelector,
        ),
      ],
    );
  }
}
