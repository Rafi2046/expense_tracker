import 'package:expense_tracker/features/notes/pages/notebook_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class UtilitiesGroup extends StatelessWidget {
  const UtilitiesGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: context.translate('utilities'),
      children: [
        SettingsOptionRow(
          icon: Icons.book_rounded,
          iconBgColor: const Color(0xFFEFEBE9),
          iconColor: const Color(0xFF6D4C41),
          title: context.translate('notebook'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotebookScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
