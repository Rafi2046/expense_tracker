import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';

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
      leadingIcon: Icons.calendar_today_outlined,
      labelText: 'Date',
      valueText: dateText,
      isValueSelected: true,
      themeColor: themeColor,
      trailingIcon: Icons.edit_calendar_outlined,
      onTap: onTap,
    );
  }
}
