import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_components/pdf_theme.dart';
export 'pdf_components/pdf_theme.dart' show PdfSummaryData;

import 'pdf_components/pdf_header.dart';
import 'pdf_components/pdf_summary.dart';
import 'pdf_components/pdf_table.dart';
import 'pdf_components/pdf_footer.dart';
import 'pdf_components/pdf_entries_note.dart';

class PdfExportService {
  // ── Cached fonts ───────────────────────────────────────────────────────
  pw.Font? _fontRegular;
  pw.Font? _fontBold;

  /// Loads Noto Sans Bengali (supports ৳, ₹, ¥, €, £ and all Latin chars).
  Future<void> _loadFonts() async {
    _fontRegular ??= await PdfGoogleFonts.notoSansBengaliRegular();
    _fontBold ??= await PdfGoogleFonts.notoSansBengaliBold();
  }

  /// Builds a premium-styled PDF [pw.Document].
  Future<pw.Document> buildDocument({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    PdfSummaryData? summaryData,
  }) async {
    await _loadFonts();

    final baseStyle = pw.TextStyle(font: _fontRegular, fontBold: _fontBold);
    final theme = pw.ThemeData.withFont(
      base: _fontRegular!,
      bold: _fontBold!,
    );

    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/app_logo/splash_logo_final.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      // Fallback if asset loading fails
    }

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28),
        header: (context) => PdfHeaderBuilder.build(title, dateRange, baseStyle, logoImage),
        footer: (context) => PdfFooterBuilder.build(context, baseStyle),
        build: (context) => [
          if (summaryData != null) ...[
            pw.SizedBox(height: 8),
            PdfSummaryBuilder.build(summaryData, baseStyle),
            pw.SizedBox(height: 20),
          ] else
            pw.SizedBox(height: 16),
          PdfTableBuilder.build(headers, rows, baseStyle),
          pw.SizedBox(height: 12),
          PdfEntriesNoteBuilder.build(rows.length, baseStyle),
        ],
      ),
    );

    return pdf;
  }

  /// Generates a PDF file and returns it.
  Future<File> generatePdf({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
    PdfSummaryData? summaryData,
  }) async {
    final pdf = await buildDocument(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
      summaryData: summaryData,
    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
