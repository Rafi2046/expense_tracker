import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme.dart';

class PdfEntriesNoteBuilder {
  static pw.Widget build(int count, pw.TextStyle baseStyle) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfTheme.lightBg,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total Entries: $count',
            style: baseStyle.copyWith(
              fontSize: 8,
              color: PdfTheme.dark,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'This report is auto-generated and may not reflect pending transactions.',
            style: baseStyle.copyWith(fontSize: 6, color: PdfTheme.mutedText),
          ),
        ],
      ),
    );
  }
}
