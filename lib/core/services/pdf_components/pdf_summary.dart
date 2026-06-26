import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme.dart';

class PdfSummaryBuilder {
  static pw.Widget build(PdfSummaryData data, pw.TextStyle baseStyle) {
    return pw.Row(
      children: [
        _buildSummaryCard(
          label: 'Total Income',
          value: '${data.currencySymbol} ${PdfTheme.formatNumber(data.totalIncome)}',
          accentColor: PdfTheme.incomeGreen,
          base: baseStyle,
        ),
        pw.SizedBox(width: 10),
        _buildSummaryCard(
          label: 'Total Expense',
          value: '${data.currencySymbol} ${PdfTheme.formatNumber(data.totalExpense)}',
          accentColor: PdfTheme.expenseRed,
          base: baseStyle,
        ),
        pw.SizedBox(width: 10),
        _buildSummaryCard(
          label: 'Net Balance',
          value: '${data.currencySymbol} ${PdfTheme.formatNumber(data.netBalance)}',
          accentColor: PdfTheme.brandPrimary,
          base: baseStyle,
          isBold: true,
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCard({
    required String label,
    required String value,
    required PdfColor accentColor,
    required pw.TextStyle base,
    bool isBold = false,
  }) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Container(
            height: 3,
            decoration: pw.BoxDecoration(color: accentColor),
          ),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: PdfTheme.white,
              border: pw.Border(
                left: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFE2E8F0),
                  width: 0.5,
                ),
                right: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFE2E8F0),
                  width: 0.5,
                ),
                bottom: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFE2E8F0),
                  width: 0.5,
                ),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label.toUpperCase(),
                  style: base.copyWith(
                    fontSize: 7,
                    color: PdfTheme.mutedText,
                    letterSpacing: 0.6,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  value,
                  style: base.copyWith(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: isBold ? accentColor : PdfTheme.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
