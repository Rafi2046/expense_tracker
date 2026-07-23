import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';
import 'package:expense_tracker/core/services/export_service.dart';
import 'package:expense_tracker/core/services/pdf_export_service.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(_loadingSnackBar(context));

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
      if (!context.mounted) return;
      messenger.showSnackBar(_errorSnackBar(context.translate('failed_to_download_pdf').replaceAll('{error}', e.toString())));
    }
  }

  Future<void> _onExcel(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(_loadingSnackBar(context));

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
      if (!context.mounted) return;
      messenger.showSnackBar(_errorSnackBar(context.translate('failed_to_export_excel').replaceAll('{error}', e.toString())));
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
      if (!context.mounted) return;
      messenger.showSnackBar(
        _errorSnackBar(context.translate('failed_to_print').replaceAll('{error}', e.toString())),
      );
    }
  }

  Future<void> _onShare(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final format = await ShareReportSheet.show(context);
    if (format == null || !context.mounted) return;
    messenger.showSnackBar(_loadingSnackBar(context));

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
      if (!context.mounted) return;
      messenger.showSnackBar(_errorSnackBar(context.translate('failed_to_share').replaceAll('{error}', e.toString())));
    }
  }

  SnackBar _loadingSnackBar(BuildContext context) {
    final theme = Theme.of(context);
    return SnackBar(
      content: Row(
        children: [
          const SizedBox(width: AppSpacing.s16,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Flexible(
            child: Text(
              context.translate('generating_report'),
              style: AppTextStyles.body.copyWith(color: Colors.white),
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
          Icon(LucideIcons.alertCircle, color: Colors.white, size: AppSpacing.s16),
          const SizedBox(width: AppSpacing.s8),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: Colors.white),
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
        padding: const EdgeInsets.only(left: AppSpacing.p16, right: AppSpacing.p16, bottom: AppSpacing.p24),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.r24),
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
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12, horizontal: AppSpacing.p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.downloadCloud,
                  label: context.translate('download'),
                  onTap: () => _onDownload(context),
                ),
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.printer,
                  label: context.translate('print_pdf'),
                  onTap: () => _onPrint(context),
                ),
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.fileText,
                  label: context.translate('excel'),
                  onTap: () => _onExcel(context),
                ),
                _buildActionItem(
                  context: context,
                  icon: LucideIcons.externalLink,
                  label: context.translate('share'),
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
            const SizedBox(height: AppSpacing.s4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTextStyles.partyFormHint.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
