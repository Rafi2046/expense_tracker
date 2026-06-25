import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportBottomActions extends StatelessWidget {
  final String reportName;

  const ReportBottomActions({
    super.key,
    required this.reportName,
  });

  void _showExportSuccess(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Report exported to $format successfully!',
              style: AppTextStyles.partySubmitButtonText.copyWith(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: AppColors.activeGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 6,
      ),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(
              context: context,
              icon: Icons.download_outlined,
              label: 'Download',
              onTap: () => _showExportSuccess(context, 'PDF/Excel'),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.print_outlined,
              label: 'Print PDF',
              onTap: () => _showExportSuccess(context, 'Printer Output'),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.table_chart_outlined,
              label: 'Excel',
              onTap: () => _showExportSuccess(context, 'Excel File'),
            ),
            _buildActionItem(
              context: context,
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () async {
                final format = await ShareReportSheet.show(context);
                if (format != null && context.mounted) {
                  _showExportSuccess(context, format.toUpperCase());
                }
              },
            ),
          ],
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
