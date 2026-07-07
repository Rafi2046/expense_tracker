extension StringMasking on String {
  String get masked => replaceAll(RegExp(r'\d'), '•');
}
