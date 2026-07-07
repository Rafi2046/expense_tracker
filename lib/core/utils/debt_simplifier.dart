class SimplifiedSettlement {
  final String fromParticipantId;
  final String toParticipantId;
  final double amount;

  SimplifiedSettlement({
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amount,
  });

  @override
  String toString() =>
      '$fromParticipantId pays $toParticipantId \$${amount.toStringAsFixed(2)}';
}

List<SimplifiedSettlement> simplifyDebts(Map<String, double> netBalances) {
  final debtors = <_Balance>[];
  final creditors = <_Balance>[];

  for (final entry in netBalances.entries) {
    final rounded = (entry.value * 100).round() / 100.0;
    if (rounded.abs() < 0.01) continue;
    if (rounded < 0) {
      debtors.add(_Balance(id: entry.key, amount: -rounded));
    } else {
      creditors.add(_Balance(id: entry.key, amount: rounded));
    }
  }

  debtors.sort((a, b) => b.amount.compareTo(a.amount));
  creditors.sort((a, b) => b.amount.compareTo(a.amount));

  final result = <SimplifiedSettlement>[];
  int di = 0, ci = 0;

  while (di < debtors.length && ci < creditors.length) {
    final debtor = debtors[di];
    final creditor = creditors[ci];
    final settled = (debtor.amount < creditor.amount) ? debtor.amount : creditor.amount;

    result.add(SimplifiedSettlement(
      fromParticipantId: debtor.id,
      toParticipantId: creditor.id,
      amount: settled,
    ));

    debtor.amount -= settled;
    creditor.amount -= settled;

    if (debtor.amount < 0.01) di++;
    if (creditor.amount < 0.01) ci++;
  }

  return result;
}

class _Balance {
  final String id;
  double amount;
  _Balance({required this.id, required this.amount});
}
