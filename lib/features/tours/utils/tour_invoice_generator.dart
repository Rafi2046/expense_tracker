import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class TourInvoiceGenerator {
  TourInvoiceGenerator._();

  static Future<void> generateAndShare({
    required Tour tour,
    required List<TourParticipant> participants,
    required List<TourExpense> expenses,
    required List<SimplifiedSettlement> settlements,
    required double totalSpent,
    required double totalOutstanding,
  }) async {
    try {
      final doc = _buildPdf(
        tour: tour,
        participants: participants,
        expenses: expenses,
        settlements: settlements,
        totalSpent: totalSpent,
        totalOutstanding: totalOutstanding,
      );

      final pdfBytes = await doc.save();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/tour_invoice_${tour.id.substring(0, 8)}.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '${tour.name} \u2014 Detailed Invoice',
        ),
      );
    } catch (e) {
      debugPrint('PDF generation error: $e');
    }
  }

  static Future<void> printPdf({
    required Tour tour,
    required List<TourParticipant> participants,
    required List<TourExpense> expenses,
    required List<SimplifiedSettlement> settlements,
    required double totalSpent,
    required double totalOutstanding,
  }) async {
    final doc = _buildPdf(
      tour: tour,
      participants: participants,
      expenses: expenses,
      settlements: settlements,
      totalSpent: totalSpent,
      totalOutstanding: totalOutstanding,
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'tour_invoice_${tour.id.substring(0, 8)}.pdf',
    );
  }

  static pw.Document _buildPdf({
    required Tour tour,
    required List<TourParticipant> participants,
    required List<TourExpense> expenses,
    required List<SimplifiedSettlement> settlements,
    required double totalSpent,
    required double totalOutstanding,
  }) {
    final pById = {for (final p in participants) p.id: p.name};
    final categoryTotals = _groupByCategory(expenses);
    final isAllSettled = totalOutstanding == 0;

    return pw.Document(
      title: '${tour.name} Invoice',
      author: 'Expense Tracker',
      subject: 'Tour Expense Invoice',
    )..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPageHeader(tour),
        footer: (context) => _buildPageFooter(),
        build: (context) => [
          _buildHeader(tour, totalSpent),
          pw.SizedBox(height: 24),
          _buildCategorySummary(categoryTotals, tour.currency),
          pw.SizedBox(height: 24),
          _buildSectionTitle('DETAILED LEDGER'),
          pw.SizedBox(height: 12),
          _buildLedgerTable(expenses, pById, tour.currency),
          pw.SizedBox(height: 24),
          _buildSectionTitle(
            isAllSettled ? 'SETTLEMENT STATUS' : 'OUTSTANDING BALANCES',
          ),
          pw.SizedBox(height: 12),
          if (isAllSettled)
            _buildAllSettledMessage()
          else
            ..._buildSettlementSection(settlements, pById, tour.currency),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────

  static pw.Widget _buildPageHeader(Tour tour) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            tour.name,
            style: pw.TextStyle(fontSize: AppFontSizes.size10, color: PdfColors.grey600),
          ),
          pw.Text(
            'Expense Tracker',
            style: pw.TextStyle(fontSize: AppFontSizes.size10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Generated via Expense Tracker - Shared Expenses Simplified',
            style: pw.TextStyle(fontSize: AppFontSizes.size8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ─── Main Header ────────────────────────────────────────────────────

  static pw.Widget _buildHeader(Tour tour, double totalSpent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: AppFontSizes.size10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal700,
                    letterSpacing: 3,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  tour.name,
                  style: pw.TextStyle(
                    fontSize: AppFontSizes.size28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  _formatDate(tour.createdAt),
                  style: pw.TextStyle(fontSize: AppFontSizes.size10, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Currency: ${tour.currency}',
                  style: pw.TextStyle(fontSize: AppFontSizes.size10, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF0FDF9),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            border: pw.Border.all(color: PdfColor.fromInt(0xFFD1FAE5)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TOTAL SPENT',
                style: pw.TextStyle(
                  fontSize: AppFontSizes.size10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              pw.Text(
                _formatAmount(totalSpent, tour.currency),
                style: pw.TextStyle(
                  fontSize: AppFontSizes.size32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF059669),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Category Summary ───────────────────────────────────────────────

  static Map<String, double> _groupByCategory(List<TourExpense> expenses) {
    final map = <String, double>{};
    for (final e in expenses) {
      final cat = e.category ?? 'Uncategorized';
      map[cat] = (map[cat] ?? 0) + e.amount;
    }
    return map;
  }

  static pw.Widget _buildCategorySummary(
    Map<String, double> categoryTotals,
    String currency,
  ) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8F9FA),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('WHERE THE MONEY WENT'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontSize: AppFontSizes.size9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
            cellStyle: pw.TextStyle(fontSize: AppFontSizes.size10, color: PdfColors.grey800),
            headerDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300),
              ),
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              ),
            ),
            headers: ['Category', 'Amount'],
            data: entries
                .map((e) => [e.key, _formatAmount(e.value, currency)])
                .toList(),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(2),
            },
            headerAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────────────────

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: AppFontSizes.size9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey500,
        letterSpacing: 2,
      ),
    );
  }

  // ─── Detailed Ledger Table ──────────────────────────────────────────

  static pw.Widget _buildLedgerTable(
    List<TourExpense> expenses,
    Map<String, String> pById,
    String currency,
  ) {
    final sorted = List<TourExpense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontSize: AppFontSizes.size9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF0F766E),
      ),
      cellStyle: pw.TextStyle(fontSize: AppFontSizes.size9, color: PdfColors.grey800),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
      headerAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerRight,
      },
      headers: ['Date', 'Expense', 'Category', 'Paid By', 'Amount'],
      data: sorted
          .map(
            (e) => [
              _formatShortDate(e.date),
              e.title,
              e.category ?? 'Uncategorized',
              pById[e.paidBy] ?? 'Unknown',
              _formatAmount(e.amount, currency),
            ],
          )
          .toList(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      headerPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        ),
      ),
    );
  }

  // ─── Settlements Section ────────────────────────────────────────────

  static pw.Widget _buildAllSettledMessage() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0FDF9),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD1FAE5)),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: 36,
            height: 36,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF2EBD85),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'v',
                style: pw.TextStyle(
                  fontSize: AppFontSizes.size18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'All settled up',
            style: pw.TextStyle(
              fontSize: AppFontSizes.size16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF065F46),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'No payments needed - everyone is even',
            style: pw.TextStyle(fontSize: AppFontSizes.size11, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildSettlementSection(
    List<SimplifiedSettlement> settlements,
    Map<String, String> pById,
    String currency,
  ) {
    return settlements.map((s) {
      final from = pById[s.fromParticipantId] ?? 'Unknown';
      final to = pById[s.toParticipantId] ?? 'Unknown';

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: PdfColors.grey200),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              to,
              style: pw.TextStyle(
                fontSize: AppFontSizes.size11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF2EBD85),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              'gets',
              style: const pw.TextStyle(fontSize: AppFontSizes.size11, color: PdfColors.grey600),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              _formatAmount(s.amount, currency),
              style: pw.TextStyle(
                fontSize: AppFontSizes.size13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFF2EBD85),
              ),
            ),
            pw.Text(
              ' from ',
              style: const pw.TextStyle(fontSize: AppFontSizes.size11, color: PdfColors.grey600),
            ),
            pw.Text(
              from,
              style: pw.TextStyle(
                fontSize: AppFontSizes.size11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromInt(0xFFDC3545),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  static String _formatAmount(double amount, String currency) {
    const prefixes = {
      'BDT': 'BDT ',
      'USD': r'$',
      'EUR': 'EUR ',
      'GBP': '\u00A3',
      'INR': 'INR ',
      'JPY': '\u00A5',
      'AED': 'AED ',
      'CAD': r'$',
    };
    final prefix = prefixes[currency] ?? r'$';
    if (amount == amount.roundToDouble()) {
      return '$prefix${amount.toStringAsFixed(0)}';
    }
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
