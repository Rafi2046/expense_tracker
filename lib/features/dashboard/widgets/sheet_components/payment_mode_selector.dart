import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_selector_tile.dart';
import 'package:flutter/material.dart';

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
      leadingIcon: Symbols.account_balance_wallet,
      labelText: 'Payment Mode',
      valueText: paymentMethod,
      isValueSelected: true,
      themeColor: themeColor,
      trailingIcon: Symbols.swap_horiz_rounded,
      onTap: onTap,
    );
  }
}
