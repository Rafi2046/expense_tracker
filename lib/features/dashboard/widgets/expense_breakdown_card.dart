import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseBreakdownItem {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  ExpenseBreakdownItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.iconColor = AppColors.activeGreen,
    this.iconBgColor = const Color(0xFFE8F8F5),
  });
}

class ExpenseBreakdownCard extends StatelessWidget {
  final String suffixText;
  final List<ExpenseBreakdownItem> items;

  const ExpenseBreakdownCard({
    super.key,
    required this.suffixText,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(
          color: (theme.dividerTheme.color ?? AppColors.dividerColor).withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
              children: [
                const TextSpan(text: 'Expense Breakdown '),
                TextSpan(
                  text: suffixText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? (item.iconBgColor == const Color(0xFFE8F8F5)
                              ? AppColors.activeGreen.withValues(alpha: 0.15)
                              : item.iconBgColor.withValues(alpha: 0.2))
                          : item.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontFamily: GoogleFonts.workSans().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontFamily: GoogleFonts.workSans().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    item.amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
