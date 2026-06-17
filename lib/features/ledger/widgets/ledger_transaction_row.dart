import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerTransactionRow extends StatelessWidget {
  final String title;
  final String dateText;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final VoidCallback onTap;

  const LedgerTransactionRow({
    super.key,
    required this.title,
    required this.dateText,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.onTap,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'dining':
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'medicine':
        return Icons.medical_services_rounded;
      case 'salary':
        return Icons.payments_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'entertainment':
        return Icons.sports_esports_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'rent':
        return Icons.home_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'dining':
      case 'food':
        return const Color(0xFFF39C12); // Orange
      case 'transport':
        return const Color(0xFF3498DB); // Blue
      case 'medicine':
        return const Color(0xFFE74C3C); // Red
      case 'salary':
        return const Color(0xFF2ECC71); // Green
      case 'freelance':
        return const Color(0xFF1ABC9C); // Teal
      case 'entertainment':
        return const Color(0xFF9B59B6); // Purple
      case 'shopping':
        return const Color(0xFFE91E63); // Pink
      case 'investment':
        return const Color(0xFF27AE60); // Emerald
      case 'rent':
        return const Color(0xFFE67E22); // Orange-Red
      default:
        return const Color(0xFF95A5A6); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = isIncome ? AppColors.activeGreen : AppColors.expensePink;
    final amountPrefix = isIncome ? '+ ' : '- ';
    final catColor = _getCategoryColor(category);
    final catIcon = _getCategoryIcon(category);
    
    final formattedAmount = (amount % 1 == 0)
        ? amount.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )
        : amount.toStringAsFixed(2).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F1F1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left Section: Category icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  catIcon,
                  color: catColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Middle Section: Title & Subtitle (Time + Category Name)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.workSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$dateText  •  $category',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right Section: Amount
              Text(
                '$amountPrefix${context.currencySymbol}$formattedAmount',
                style: GoogleFonts.workSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
