import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  pw.Document buildDocument({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            dateRange,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 6),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 16),
          _buildTable(headers, rows),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated on ${DateTime.now().toLocal().toString().substring(0, 19)}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                '${rows.length} entries',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ),
      ),
    );

    return pdf;
  }

  Future<File> generatePdf({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) async {
    final pdf = buildDocument(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildTable(List<String> headers, List<Map<String, dynamic>> rows) {
    final headerColor = PdfColor.fromInt(0xFF34495E);
    final accentColor = PdfColor.fromInt(0xFF2EBD85);
    final evenRowColor = PdfColor(0.96, 0.97, 0.98);
    final oddRowColor = PdfColors.white;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: pw.Text(
              h,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          )).toList(),
        ),
        ...rows.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final row = entry.value;
          final bgColor = rowIndex.isEven ? evenRowColor : oddRowColor;

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bgColor),
            children: headers.map((h) {
              final cellValue = row[h]?.toString() ?? '';
              final isAmount = h.toLowerCase().contains('amount') ||
                  h.toLowerCase().contains('balance') ||
                  h.toLowerCase().contains('total');
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: pw.Text(
                  cellValue,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: isAmount ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: isAmount ? accentColor : PdfColors.blueGrey800,
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
