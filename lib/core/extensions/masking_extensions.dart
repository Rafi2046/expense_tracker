extension StringMasking on String {
  String get masked {
    final match = RegExp(r'\d').firstMatch(this);
    if (match == null) return '***';
    return '${substring(0, match.start)} ***';
  }
}
