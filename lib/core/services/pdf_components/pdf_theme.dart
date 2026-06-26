import 'package:pdf/pdf.dart';

class PdfSummaryData {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final String currencySymbol;

  const PdfSummaryData({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.currencySymbol,
  });
}

class PdfTheme {
  static const brandPrimary = PdfColor.fromInt(0xFF0C4E3C);
  static const brandAccent = PdfColor.fromInt(0xFF2EBD85);
  static const headerBg = PdfColor.fromInt(0xFF1A2B3C);
  static const incomeGreen = PdfColor.fromInt(0xFF2EBD85);
  static const expenseRed = PdfColor.fromInt(0xFFDC3545);
  static const mutedText = PdfColor.fromInt(0xFF6B7280);
  static const lightBg = PdfColor.fromInt(0xFFF8FAFC);
  static const zebraRow = PdfColor.fromInt(0xFFF1F5F9);
  static const white = PdfColors.white;
  static const dark = PdfColor.fromInt(0xFF1E293B);

  static bool isAmountColumn(String header) {
    final h = header.toLowerCase();
    return h.contains('amount') ||
        h.contains('balance') ||
        h.contains('total') ||
        h.contains('credit') ||
        h.contains('debit');
  }

  static String formatNumber(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final parts = absValue.toStringAsFixed(0).split('');

    final buffer = StringBuffer();
    for (int i = parts.length - 1, groupCount = 0; i >= 0; i--) {
      if (groupCount == 3 || (groupCount > 3 && (groupCount - 3) % 2 == 0)) {
        buffer.write(',');
      }
      buffer.write(parts[i]);
      groupCount++;
    }

    final formatted = buffer.toString().split('').reversed.join();
    return isNegative ? '-$formatted' : formatted;
  }
}
