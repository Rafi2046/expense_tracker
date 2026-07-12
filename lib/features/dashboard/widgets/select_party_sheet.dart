import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_components/party_selector_sheet.dart';
import 'package:flutter/material.dart';

Future<void> showSelectPartySheet({
  required BuildContext context,
  required DebtProvider debtProvider,
  String? selectedPartyName,
  bool isIncome = false,
  required ValueChanged<String> onSelect,
  required VoidCallback onClear,
}) {
  final Map<String, DebtItem> uniqueParties = {};
  for (var item in debtProvider.items) {
    if (!uniqueParties.containsKey(item.name) ||
        (uniqueParties[item.name]?.phone == null && item.phone != null)) {
      uniqueParties[item.name] = item;
    }
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PartySelectorSheet(
      uniqueParties: uniqueParties,
      selectedPartyName: selectedPartyName,
      isIncome: isIncome,
      onSelect: (name) {
        onSelect(name);
        Navigator.pop(ctx);
      },
      onClear: () {
        onClear();
        Navigator.pop(ctx);
      },
    ),
  );
}
