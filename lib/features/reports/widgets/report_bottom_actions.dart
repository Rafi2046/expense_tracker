import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';
import 'package:expense_tracker/core/services/export_service.dart';
import 'package:expense_tracker/core/services/pdf_export_service.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
              style: TextStyle(color: Colors.white, fontSize: AppFontSizes.size14),
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
          Icon(LucideIcons.alertCircle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: AppFontSizes.size14),
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.download,
                  label: 'Download',
                  onTap: () => _onDownload(context),
                ),
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.printer,
                  label: 'Print PDF',
                  onTap: () => _onPrint(context),
                ),
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.table,
                  label: 'Excel',
                  onTap: () => _onExcel(context),
                ),
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.share,
                  label: 'Share',
                  onTap: () => _onShare(context),
                ),
              ],
            ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.primaryColor, size: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSizes.size10,
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
