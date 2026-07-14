import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PdfFooterBuilder {
  static pw.Widget build(pw.Context context, pw.TextStyle baseStyle) {
    final now = DateTime.now().toLocal();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColor.fromInt(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated on $dateStr',
            style: baseStyle.copyWith(fontSize: AppFontSizes.size7, color: PdfTheme.mutedText),
          ),
          pw.Row(children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: PdfTheme.brandAccent,
                borderRadius: pw.BorderRadius.circular(3),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              'BudgetMint',
              style: baseStyle.copyWith(
                fontSize: AppFontSizes.size7,
                color: PdfTheme.brandPrimary,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ]),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: baseStyle.copyWith(fontSize: AppFontSizes.size7, color: PdfTheme.mutedText),
          ),
        ],
      ),
    );
  }
}
