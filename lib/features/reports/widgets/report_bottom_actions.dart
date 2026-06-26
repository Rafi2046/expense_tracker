import 'package:material_symbols_icons/symbols.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';
import 'package:expense_tracker/core/services/export_service.dart';
import 'package:expense_tracker/core/services/pdf_export_service.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportBottomActions extends StatelessWidget {
  final String reportName;
  final String title;
  final String dateSubtitle;
  final List<String> headers;
  final List<Map<String, dynamic>> rows;
  final PdfSummaryData? summaryData;

  const ReportBottomActions({
    super.key,
    required this.reportName,
    required this.title,
    required this.dateSubtitle,
    required this.headers,
    required this.rows,
    this.summaryData,
  });

  Future<void> _onDownload(BuildContext context) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(_loadingSnackBar(theme));

    try {
      final service = ExportService();
      final file = await service.exportPdf(
        title: title,
        dateRange: dateSubtitle,
        headers: headers,
        rows: rows,
        summaryData: summaryData,
      );
      messenger.hideCurrentSnackBar();
      await OpenFilex.open(file.path);
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(_errorSnackBar('Failed to download PDF: $e'));
    }
  }

  Future<void> _onExcel(BuildContext context) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(_loadingSnackBar(theme));

    try {
      final service = ExportService();
      final file = await service.exportExcel(
        title: title,
        dateRange: dateSubtitle,
        headers: headers,
        rows: rows,
      );
      messenger.hideCurrentSnackBar();
      await OpenFilex.open(file.path);
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(_errorSnackBar('Failed to export Excel: $e'));
    }
  }

  Future<void> _onPrint(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final service = ExportService();
      await Printing.layoutPdf(
        onLayout: service.buildPdfLayoutCallback(
          title: title,
          dateRange: dateSubtitle,
          headers: headers,
          rows: rows,
          summaryData: summaryData,
        ),
        name: title,
      );
    } catch (e) {
      messenger.showSnackBar(
        _errorSnackBar('Failed to print: $e'),
      );
    }
  }

  Future<void> _onShare(BuildContext context) async {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final format = await ShareReportSheet.show(context);
    if (format == null || !context.mounted) return;
    messenger.showSnackBar(_loadingSnackBar(theme));

    try {
      final service = ExportService();

      if (format == 'pdf') {
        final file = await service.exportPdf(
          title: title,
          dateRange: dateSubtitle,
          headers: headers,
          rows: rows,
          summaryData: summaryData,
        );
        messenger.hideCurrentSnackBar();
        await service.shareFile(file);
      } else if (format == 'image') {
        await service.shareAsImage(
          title: title,
          dateRange: dateSubtitle,
          headers: headers,
          rows: rows,
          summaryData: summaryData,
        );
        messenger.hideCurrentSnackBar();
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(_errorSnackBar('Failed to share: $e'));
    }
  }

  SnackBar _loadingSnackBar(ThemeData theme) {
    return SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text(
              'Generating report...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: theme.primaryColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 30),
    );
  }


  SnackBar _errorSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Symbols.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? (isDark ? Colors.white10 : const Color(0xFFF1F1F1)),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                context: context,
                icon: Symbols.download,
                label: 'Download',
                onTap: () => _onDownload(context),
              ),
              _buildActionItem(
                context: context,
                icon: Symbols.print,
                label: 'Print PDF',
                onTap: () => _onPrint(context),
              ),
              _buildActionItem(
                context: context,
                icon: Symbols.table_chart,
                label: 'Excel',
                onTap: () => _onExcel(context),
              ),
              _buildActionItem(
                context: context,
                icon: Symbols.share,
                label: 'Share',
                onTap: () => _onShare(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.primaryColor, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: GoogleFonts.workSans().fontFamily,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
