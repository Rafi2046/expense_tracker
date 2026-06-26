import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme.dart';

class PdfHeaderBuilder {
  static pw.Widget build(String title, String dateRange, pw.TextStyle baseStyle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfTheme.brandAccent, width: 2),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Brand mark
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: PdfTheme.brandPrimary,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'ET',
              style: baseStyle.copyWith(
                color: PdfTheme.white,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Expense Tracker',
                  style: baseStyle.copyWith(
                    fontSize: 10,
                    color: PdfTheme.mutedText,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  title,
                  style: baseStyle.copyWith(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfTheme.dark,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'FINANCIAL REPORT',
                style: baseStyle.copyWith(
                  fontSize: 8,
                  color: PdfTheme.brandPrimary,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfTheme.lightBg,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFE2E8F0),
                    width: 0.5,
                  ),
                ),
                child: pw.Text(
                  dateRange,
                  style: baseStyle.copyWith(
                    fontSize: 8,
                    color: PdfTheme.dark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
