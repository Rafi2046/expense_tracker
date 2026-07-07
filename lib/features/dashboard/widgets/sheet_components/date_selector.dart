import 'package:material_symbols_icons/symbols.dart';
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
      leadingIcon: Symbols.calendar_today,
      labelText: 'Date',
      valueText: dateText,
      isValueSelected: true,
      themeColor: themeColor,
      trailingIcon: Symbols.edit_calendar,
      onTap: onTap,
    );
  }
}
