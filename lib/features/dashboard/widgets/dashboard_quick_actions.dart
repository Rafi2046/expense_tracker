import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardQuickActions extends StatelessWidget {
  final Function(String) onActionTap;

  const DashboardQuickActions({
    super.key,
    required this.onActionTap,
  });

  Widget _buildActionItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () => onActionTap(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F5), // Light green background
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.activeGreen,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF31394D),
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: GoogleFonts.workSans().fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionItem(Icons.add, 'Add'),
            _buildActionItem(Icons.swap_horiz, 'Transfer'),
            _buildActionItem(Icons.payments_outlined, 'Pay'),
            _buildActionItem(Icons.qr_code_scanner, 'Scan'),
          ],
        ),
      ],
    );
  }
}
