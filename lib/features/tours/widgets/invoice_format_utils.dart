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
  return amount == amount.roundToDouble()
      ? '$sym${amount.toStringAsFixed(0)}'
      : '$sym${amount.toStringAsFixed(2)}';
}

String formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatShortDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
