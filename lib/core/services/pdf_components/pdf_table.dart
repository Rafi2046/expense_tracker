import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_theme.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PdfTableBuilder {
  static pw.Widget build(
    List<String> headers,
    List<Map<String, dynamic>> rows,
    pw.TextStyle baseStyle,
  ) {
    return pw.Table(
      border: null,
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfTheme.headerBg,
          ),
          children: headers.map((h) {
            final isAmount = PdfTheme.isAmountColumn(h);
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              child: pw.Text(
                h,
                style: baseStyle.copyWith(
                  fontSize: AppFontSizes.size8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfTheme.white,
                  letterSpacing: 0.4,
                ),
                textAlign: isAmount ? pw.TextAlign.right : pw.TextAlign.left,
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final idx = entry.key;
          final row = entry.value;
          final bgColor = idx.isEven ? PdfTheme.white : PdfTheme.zebraRow;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: bgColor,
              border: const pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFE2E8F0),
                  width: 0.3,
                ),
              ),
            ),
            children: headers.map((h) {
              final cellValue = row[h]?.toString() ?? '';
              final isAmount = PdfTheme.isAmountColumn(h);
              final isType = h.toLowerCase() == 'type';

              PdfColor textColor = PdfTheme.dark;
              pw.FontWeight fontWeight = pw.FontWeight.normal;

              if (isAmount) {
                fontWeight = pw.FontWeight.bold;
                textColor = PdfTheme.brandAccent;
              }
              if (isType) {
                final lower = cellValue.toLowerCase();
                if (lower.contains('income') || lower.contains('in')) {
                  textColor = PdfTheme.incomeGreen;
                } else if (lower.contains('expense') || lower.contains('out')) {
                  textColor = PdfTheme.expenseRed;
                }
              }

              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: pw.Text(
                  cellValue,
                  style: baseStyle.copyWith(
                    fontSize: AppFontSizes.size8,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                  textAlign: isAmount ? pw.TextAlign.right : pw.TextAlign.left,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
