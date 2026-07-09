import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentModeSelector extends StatelessWidget {
  final String paymentMethod;
  final Color themeColor;
  final VoidCallback onTap;

  const PaymentModeSelector({
    super.key,
    required this.paymentMethod,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TransactionSelectorTile(
      leadingIcon: LucideIcons.wallet,
      labelText: 'Payment Mode',
      valueText: paymentMethod,
      isValueSelected: true,
      themeColor: themeColor,
      trailingIcon: LucideIcons.arrowLeftRight,
      onTap: onTap,
    );
  }
}
