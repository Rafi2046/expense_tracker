import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReportBottomActions extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onPrint;
  final VoidCallback onExcel;
  final VoidCallback onShare;

  const ReportBottomActions({
    super.key,
    required this.onDownload,
    required this.onPrint,
    required this.onExcel,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            icon: Icons.download_outlined,
            label: 'Download',
            onTap: onDownload,
          ),
          _buildActionItem(
            icon: Icons.print_outlined,
            label: 'Print PDF',
            onTap: onPrint,
          ),
          _buildActionItem(
            icon: Icons.table_chart_outlined,
            label: 'Excel',
            onTap: onExcel,
          ),
          _buildActionItem(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.activeGreen, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.reportSectionHeader.copyWith(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
