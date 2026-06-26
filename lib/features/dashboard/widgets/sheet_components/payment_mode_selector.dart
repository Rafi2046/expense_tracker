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
      leadingIcon: Icons.account_balance_wallet_outlined,
      labelText: 'Payment Mode',
      valueText: paymentMethod,
      isValueSelected: true,
      themeColor: themeColor,
      trailingIcon: Icons.swap_horiz_rounded,
      onTap: onTap,
    );
  }
}
