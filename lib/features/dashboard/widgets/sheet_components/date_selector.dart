import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DateSelector extends StatelessWidget {
  final String dateText;
  final Color themeColor;
  final VoidCallback onTap;

  const DateSelector({
    super.key,
    required this.dateText,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TransactionSelectorTile(
      leadingIcon: LucideIcons.calendar,
      labelText: context.translate('date'),
      valueText: dateText,
      isValueSelected: true,
      themeColor: themeColor,
      trailingIcon: LucideIcons.edit,
      onTap: onTap,
    );
  }
}
