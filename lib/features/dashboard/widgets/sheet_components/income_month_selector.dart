import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeMonthSelector extends StatelessWidget {
  final String? selectedIncomeMonth;
  final Color themeColor;
  final VoidCallback onTap;

  const IncomeMonthSelector({
    super.key,
    required this.selectedIncomeMonth,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TransactionSelectorTile(
      leadingIcon: LucideIcons.calendar,
      labelText: 'Income Month',
      valueText: selectedIncomeMonth ?? 'Select Month',
      isValueSelected: selectedIncomeMonth != null,
      themeColor: themeColor,
      trailingIcon: LucideIcons.arrowRight,
      onTap: onTap,
    );
  }
}
