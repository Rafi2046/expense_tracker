import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'pdf_export_service.dart';
import 'excel_export_service.dart';

enum ExportFormat { pdf, excel }

class ExportService {
  final PdfExportService _pdfService;
  final ExcelExportService _excelService;

  ExportService({
    PdfExportService? pdfService,
    ExcelExportService? excelService,
  })  : _pdfService = pdfService ?? PdfExportService(),
        _excelService = excelService ?? ExcelExportService();

  Future<File> exportPdf({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) {
    return _pdfService.generatePdf(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
    );
  }

  Future<File> exportExcel({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) {
    return _excelService.generateExcel(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
    );
  }

  Future<File> export({
    required ExportFormat format,
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) {
    return format == ExportFormat.pdf
        ? exportPdf(title: title, dateRange: dateRange, headers: headers, rows: rows)
        : exportExcel(title: title, dateRange: dateRange, headers: headers, rows: rows);
  }

  LayoutCallback buildPdfLayoutCallback({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) {
    return (PdfPageFormat format) async {
      final doc = _pdfService.buildDocument(
        title: title,
        dateRange: dateRange,
        headers: headers,
        rows: rows,
        pageFormat: format,
      );
      final bytes = await doc.save();
      return bytes;
    };
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: file.path.endsWith('.pdf') ? 'PDF Report' : 'Excel Report',
      ),
    );
  }

  Future<void> exportAndShare({
    required ExportFormat format,
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
  }) async {
    final file = await export(
      format: format,
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
    );
    await shareFile(file);
  }
}
