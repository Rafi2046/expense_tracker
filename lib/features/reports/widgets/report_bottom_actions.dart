import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F1F1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
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
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.activeGreen, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: GoogleFonts.workSans().fontFamily,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
