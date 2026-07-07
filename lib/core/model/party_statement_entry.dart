class PartyStatementEntry {
  final String id;
  final String partyName;
  final String description;
  final double amount;
  final bool isInflow;
  final DateTime dateTime;
  final bool isOpeningBalance;

  PartyStatementEntry({
    required this.id,
    required this.partyName,
    required this.description,
    required this.amount,
    required this.isInflow,
    required this.dateTime,
    this.isOpeningBalance = false,
  });
}
