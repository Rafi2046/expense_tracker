import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/category_utils.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class LedgerTransactionRow extends StatelessWidget {
  final String title;
  final String dateText;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? incomeMonth;
  final bool isMasked;

  const LedgerTransactionRow({
    super.key,
    required this.title,
    required this.dateText,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.onTap,
    this.onDelete,
    this.incomeMonth,
    this.isMasked = false,
  });

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = isIncome ? AppColors.activeGreen : AppColors.expensePink;
    final amountPrefix = isIncome ? '+ ' : '- ';
    final catColor = CategoryUtils.getColor(category);
    final catIcon = CategoryUtils.getIcon(category);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            children: [
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
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toTitleCase(category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title.isNotEmpty ? '$title  •  $dateText' : dateText,
                      style: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amountPrefix,
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size15,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              PrivacyMaskedText(
                amount: amount,
                isMasked: isMasked,
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size15,
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
