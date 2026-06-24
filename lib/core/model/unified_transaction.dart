class UnifiedTransaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime dateTime;
  final String type; // 'Income', 'Expense', 'Payment In', 'Payment Out'
  final String? partyName;
  final String paymentMethod; // 'Cash' or 'Bank'

  UnifiedTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateTime,
    required this.type,
    this.partyName,
    this.paymentMethod = 'Cash',
  });
}
