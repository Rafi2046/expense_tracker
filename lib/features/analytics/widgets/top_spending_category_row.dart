import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopSpendingCategoryItem {
  final String title;
  final String subtitle;
  final double amount;
  final double percentage;
  final IconData icon;

  TopSpendingCategoryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.percentage,
    required this.icon,
  });
}

class TopSpendingCategoryRow extends StatelessWidget {
  final TopSpendingCategoryItem item;

  const TopSpendingCategoryRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // Icon in rounded square
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: const Color(0xFF4A5568),
              size: 17,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: GoogleFonts.workSans(
                    fontSize: 10.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          // Trailing (Amount & Percentage)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${context.currencySymbol}${item.amount.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}',
                style: GoogleFonts.workSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.workSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.activeRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
