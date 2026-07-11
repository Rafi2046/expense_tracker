import 'package:expense_tracker/features/analytics/pages/analytics_screen.dart';
import 'package:expense_tracker/features/settings/pages/manage_categories_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ManagementGroup extends StatelessWidget {
  final VoidCallback onShowReportSelector;

  const ManagementGroup({super.key, required this.onShowReportSelector});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: context.translate('management'),
      children: [
        SettingsOptionRow(
          icon: LucideIcons.grid,
          title: context.translate('manage_categories'),
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
          icon: LucideIcons.barChart,
          title: context.translate('analytics'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyticsScreen(),
              ),
            );
          },
        ),
        SettingsOptionRow(
          icon: LucideIcons.fileText,
          title: context.translate('view_reports'),
          onTap: onShowReportSelector,
        ),
      ],
    );
  }
}
