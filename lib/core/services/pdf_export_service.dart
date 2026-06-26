import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Data class to pass optional financial summary into the PDF header.
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

class PdfExportService {
  // ── Brand palette ──────────────────────────────────────────────────────
  static const _brandPrimary = PdfColor.fromInt(0xFF0C4E3C);
  static const _brandAccent = PdfColor.fromInt(0xFF2EBD85);
  static const _headerBg = PdfColor.fromInt(0xFF1A2B3C);
  static const _incomeGreen = PdfColor.fromInt(0xFF2EBD85);
  static const _expenseRed = PdfColor.fromInt(0xFFDC3545);
  static const _mutedText = PdfColor.fromInt(0xFF6B7280);
  static const _lightBg = PdfColor.fromInt(0xFFF8FAFC);
  static const _zebraRow = PdfColor.fromInt(0xFFF1F5F9);
  static const _white = PdfColors.white;
  static const _dark = PdfColor.fromInt(0xFF1E293B);

  // ── Cached fonts ───────────────────────────────────────────────────────
  pw.Font? _fontRegular;
  pw.Font? _fontBold;

  /// Loads Noto Sans Bengali (supports ৳, ₹, ¥, €, £ and all Latin chars).
  /// The printing package's PdfGoogleFonts downloads & caches automatically.
  Future<void> _loadFonts() async {
    _fontRegular ??= await PdfGoogleFonts.notoSansBengaliRegular();
    _fontBold ??= await PdfGoogleFonts.notoSansBengaliBold();
  }

  /// Builds a premium-styled PDF [pw.Document].
  ///
  /// Provide [summaryData] to show a financial summary section at the top.
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

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 28),
        header: (context) => _buildHeader(title, dateRange, baseStyle),
        footer: (context) => _buildFooter(context, baseStyle),
        build: (context) => [
          if (summaryData != null) ...[
            pw.SizedBox(height: 8),
            _buildSummarySection(summaryData, baseStyle),
            pw.SizedBox(height: 20),
          ] else
            pw.SizedBox(height: 16),
          _buildTable(headers, rows, baseStyle),
          pw.SizedBox(height: 12),
          _buildEntriesNote(rows.length, baseStyle),
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

  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║  HEADER                                                             ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  pw.Widget _buildHeader(String title, String dateRange, pw.TextStyle base) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _brandAccent, width: 2),
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
              color: _brandPrimary,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'ET',
              style: base.copyWith(
                color: _white,
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
                  style: base.copyWith(
                    fontSize: 10,
                    color: _mutedText,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  title,
                  style: base.copyWith(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _dark,
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
                style: base.copyWith(
                  fontSize: 8,
                  color: _brandPrimary,
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
                  color: _lightBg,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(
                    color: const PdfColor.fromInt(0xFFE2E8F0),
                    width: 0.5,
                  ),
                ),
                child: pw.Text(
                  dateRange,
                  style: base.copyWith(
                    fontSize: 8,
                    color: _dark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║  SUMMARY SECTION                                                    ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  pw.Widget _buildSummarySection(PdfSummaryData data, pw.TextStyle base) {
    return pw.Row(
      children: [
        _buildSummaryCard(
          label: 'Total Income',
          value: '${data.currencySymbol} ${_formatNumber(data.totalIncome)}',
          accentColor: _incomeGreen,
          base: base,
        ),
        pw.SizedBox(width: 10),
        _buildSummaryCard(
          label: 'Total Expense',
          value: '${data.currencySymbol} ${_formatNumber(data.totalExpense)}',
          accentColor: _expenseRed,
          base: base,
        ),
        pw.SizedBox(width: 10),
        _buildSummaryCard(
          label: 'Net Balance',
          value: '${data.currencySymbol} ${_formatNumber(data.netBalance)}',
          accentColor: _brandPrimary,
          base: base,
          isBold: true,
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCard({
    required String label,
    required String value,
    required PdfColor accentColor,
    required pw.TextStyle base,
    bool isBold = false,
  }) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          // Accent top bar
          pw.Container(
            height: 3,
            decoration: pw.BoxDecoration(color: accentColor),
          ),
          // Card body with uniform border (no top side)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: _white,
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
                    color: _mutedText,
                    letterSpacing: 0.6,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  value,
                  style: base.copyWith(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: isBold ? accentColor : _dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║  TABLE                                                              ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  pw.Widget _buildTable(
    List<String> headers,
    List<Map<String, dynamic>> rows,
    pw.TextStyle base,
  ) {
    return pw.Table(
      border: null,
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: _headerBg,
          ),
          children: headers.map((h) {
            final isAmount = _isAmountColumn(h);
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              child: pw.Text(
                h,
                style: base.copyWith(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: _white,
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
          final bgColor = idx.isEven ? _white : _zebraRow;

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
              final isAmount = _isAmountColumn(h);
              final isType = h.toLowerCase() == 'type';

              PdfColor textColor = _dark;
              pw.FontWeight fontWeight = pw.FontWeight.normal;

              if (isAmount) {
                fontWeight = pw.FontWeight.bold;
                textColor = _brandAccent;
              }
              if (isType) {
                final lower = cellValue.toLowerCase();
                if (lower.contains('income') || lower.contains('in')) {
                  textColor = _incomeGreen;
                } else if (lower.contains('expense') || lower.contains('out')) {
                  textColor = _expenseRed;
                }
              }

              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: pw.Text(
                  cellValue,
                  style: base.copyWith(
                    fontSize: 8,
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

  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║  FOOTER                                                             ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  pw.Widget _buildFooter(pw.Context context, pw.TextStyle base) {
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
            style: base.copyWith(fontSize: 7, color: _mutedText),
          ),
          pw.Row(children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: _brandAccent,
                borderRadius: pw.BorderRadius.circular(3),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              'Expense Tracker',
              style: base.copyWith(
                fontSize: 7,
                color: _brandPrimary,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ]),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: base.copyWith(fontSize: 7, color: _mutedText),
          ),
        ],
      ),
    );
  }

  // ── Entries note ───────────────────────────────────────────────────────

  pw.Widget _buildEntriesNote(int count, pw.TextStyle base) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total Entries: $count',
            style: base.copyWith(
              fontSize: 8,
              color: _dark,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'This report is auto-generated and may not reflect pending transactions.',
            style: base.copyWith(fontSize: 6, color: _mutedText),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  bool _isAmountColumn(String header) {
    final h = header.toLowerCase();
    return h.contains('amount') ||
        h.contains('balance') ||
        h.contains('total') ||
        h.contains('credit') ||
        h.contains('debit');
  }

  String _formatNumber(double value) {
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
