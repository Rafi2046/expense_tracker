import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
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
    PdfSummaryData? summaryData,
  }) {
    return _pdfService.generatePdf(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
      summaryData: summaryData,
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
    PdfSummaryData? summaryData,
  }) {
    return format == ExportFormat.pdf
        ? exportPdf(
            title: title,
            dateRange: dateRange,
            headers: headers,
            rows: rows,
            summaryData: summaryData,
          )
        : exportExcel(
            title: title,
            dateRange: dateRange,
            headers: headers,
            rows: rows,
          );
  }

  LayoutCallback buildPdfLayoutCallback({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
    PdfSummaryData? summaryData,
  }) {
    return (PdfPageFormat format) async {
      final doc = await _pdfService.buildDocument(
        title: title,
        dateRange: dateRange,
        headers: headers,
        rows: rows,
        pageFormat: format,
        summaryData: summaryData,
      );
      final bytes = await doc.save();
      return bytes;
    };
  }

  // ══════════════════════════════════════════════════════════════════════
  //  IMAGE EXPORT  –  Rasterizes the PDF into a high-quality PNG
  // ══════════════════════════════════════════════════════════════════════

  /// Converts the report into a PNG image.
  ///
  /// Uses [Printing.raster] to rasterize each page at the given [dpi]
  /// (default 300 for print-quality). If the PDF has multiple pages,
  /// all pages are stitched vertically into one tall image.
  Future<File> exportAsImage({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
    PdfSummaryData? summaryData,
    double dpi = 300,
  }) async {
    // 1. Build the PDF document
    final doc = await _pdfService.buildDocument(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
      summaryData: summaryData,
    );
    final pdfBytes = await doc.save();

    // 2. Rasterize all pages into PNG byte arrays
    final List<Uint8List> pageImages = [];
    await for (final page in Printing.raster(pdfBytes, dpi: dpi)) {
      final png = await page.toPng();
      pageImages.add(png);
    }

    if (pageImages.isEmpty) {
      throw Exception('Failed to rasterize PDF — no pages produced.');
    }

    Uint8List finalPng;

    if (pageImages.length == 1) {
      // Single page — use directly
      finalPng = pageImages.first;
    } else {
      // Multiple pages — stitch vertically
      finalPng = await _stitchImagesVertically(pageImages);
    }

    // 3. Save to temp file
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/report_$timestamp.png');
    await file.writeAsBytes(finalPng);
    return file;
  }

  /// Shares the report as a PNG image via the system share sheet.
  Future<void> shareAsImage({
    required String title,
    required String dateRange,
    required List<String> headers,
    required List<Map<String, dynamic>> rows,
    PdfSummaryData? summaryData,
  }) async {
    final file = await exportAsImage(
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
      summaryData: summaryData,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: '$title — Report Image',
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  FILE SHARING
  // ══════════════════════════════════════════════════════════════════════

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
    PdfSummaryData? summaryData,
  }) async {
    final file = await export(
      format: format,
      title: title,
      dateRange: dateRange,
      headers: headers,
      rows: rows,
      summaryData: summaryData,
    );
    await shareFile(file);
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════

  /// Decodes multiple PNG byte arrays and stitches them vertically
  /// into a single tall PNG image.
  Future<Uint8List> _stitchImagesVertically(List<Uint8List> pngPages) async {
    // Decode all images
    final List<ui.Image> images = [];
    for (final pngBytes in pngPages) {
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      images.add(frame.image);
    }

    // Calculate total dimensions
    int totalHeight = 0;
    int maxWidth = 0;
    for (final img in images) {
      totalHeight += img.height;
      if (img.width > maxWidth) maxWidth = img.width;
    }

    // Create a canvas and paint each page
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    double yOffset = 0;
    for (final img in images) {
      canvas.drawImage(img, ui.Offset(0, yOffset), ui.Paint());
      yOffset += img.height;
    }

    final picture = recorder.endRecording();
    final composited = await picture.toImage(maxWidth, totalHeight);
    final byteData = await composited.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Dispose decoded images
    for (final img in images) {
      img.dispose();
    }
    composited.dispose();

    if (byteData == null) {
      throw Exception('Failed to encode stitched image to PNG.');
    }

    return byteData.buffer.asUint8List();
  }
}
