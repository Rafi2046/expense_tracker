class LedgerItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime dateTime;
  final bool isCredit; // true = Money In, false = Money Out
  double runningBalance;

  LedgerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateTime,
    required this.isCredit,
    this.runningBalance = 0.0,
  });
}
