const _currencySymbols = {
  'BDT': '\u09F3',
  'USD': r'$',
  'EUR': '\u20AC',
  'GBP': '\u00A3',
  'INR': '\u20B9',
  'JPY': '\u00A5',
  'AED': '\u062F.\u0625',
  'CAD': r'$',
};

String formatAmount(double amount, String currency) {
  final sym = _currencySymbols[currency] ?? r'$';
  if (!amount.isFinite) return '$sym—';

  final abs = amount.abs();
  // Compact so absurd / corrupted doubles don't blow up invoice layout.
  if (abs >= 1e12) {
    return '$sym${_compact(amount)}';
  }

  return amount == amount.roundToDouble()
      ? '$sym${amount.toStringAsFixed(0)}'
      : '$sym${amount.toStringAsFixed(2)}';
}

String _compact(double amount) {
  final abs = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (abs >= 1e15) return '$sign${(amount / 1e15).toStringAsFixed(2)}Q';
  if (abs >= 1e12) return '$sign${(amount / 1e12).toStringAsFixed(2)}T';
  if (abs >= 1e9) return '$sign${(amount / 1e9).toStringAsFixed(2)}B';
  return amount.toStringAsFixed(2);
}

String formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatShortDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
