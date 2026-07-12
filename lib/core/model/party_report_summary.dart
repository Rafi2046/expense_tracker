class PartyReportSummary {
  final String name;
  final String? phone;
  final double netBalance; // positive = Receivable (To Receive), negative = Payable (To Give)
  final int transactionCount;

  PartyReportSummary({
    required this.name,
    this.phone,
    required this.netBalance,
    required this.transactionCount,
  });

  String get initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].runes.isNotEmpty ? String.fromCharCode(parts[0].runes.first).toUpperCase() : '';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
