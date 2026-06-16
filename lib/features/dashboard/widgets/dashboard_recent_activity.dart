import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentActivityItem {
  final String title;
  final String category;
  final String timeText;
  final double amount;
  final bool isIncome;
  final IconData icon;

  RecentActivityItem({
    required this.title,
    required this.category,
    required this.timeText,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });
}

class DashboardRecentActivity extends StatelessWidget {
  final List<RecentActivityItem> items;
  final VoidCallback onViewAllTap;
  final Function(RecentActivityItem) onItemTap;

  const DashboardRecentActivity({
    super.key,
    required this.items,
    required this.onViewAllTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final List<Widget> listWidgets = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isInc = item.isIncome;

      listWidgets.add(
        InkWell(
          onTap: () => onItemTap(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                // Icon circle container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isInc ? const Color(0xFFE8F8F5) : const Color(0xFFF2F4F4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: isInc ? AppColors.activeGreen : const Color(0xFF31394D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and subtitle info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.category}  •  ${item.timeText}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing amount
                Text(
                  '${isInc ? '+' : '-'}${context.formatAmount(item.amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isInc ? AppColors.activeGreen : AppColors.expensePink,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (i < items.length - 1) {
        listWidgets.add(Container(
          color: AppColors.dividerColor.withValues(alpha: 0.3),
          height: 1.0,
        ));
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAllTap,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.activeGreen,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider below card header
          Container(
            color: AppColors.dividerColor.withValues(alpha: 0.3),
            height: 1.0,
          ),

          // Option list
          Column(
            children: listWidgets,
          ),
        ],
      ),
    );
  }
}
