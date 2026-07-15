import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class BudgetStatusItem {
  final String categoryName;
  final double percentage;
  final Color color;

  BudgetStatusItem({
    required this.categoryName,
    required this.percentage,
    required this.color,
  });
}

class DashboardBudgetStatus extends StatelessWidget {
  final List<BudgetStatusItem> items;
  final VoidCallback? onTap;

  const DashboardBudgetStatus({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color:
                Theme.of(context).dividerTheme.color ??
                AppColors.dividerColor.withValues(alpha: 0.5),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Label
            Padding(
              padding: const EdgeInsets.only(left: 2.0, bottom: 10.0),
              child: Text(
                context.translate('budget_status').toUpperCase(),
                style: TextStyle(
                  fontSize: AppFontSizes.size10,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white60
                      : AppColors.loginSubTitle.withValues(alpha: 0.8),
                  fontFamily: TextStyle().fontFamily,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Budget items progress bars list
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final labelColor = isDark
                    ? Colors.white70
                    : const Color(0xFF31394D);
                return Padding(
                  padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.translate(item.categoryName.toLowerCase()),
                            style: TextStyle(
                              fontSize: AppFontSizes.size12,
                              fontWeight: FontWeight.w600,
                              color: labelColor,
                              fontFamily: TextStyle().fontFamily,
                            ),
                          ),
                          Text(
                            '${item.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: AppFontSizes.size12,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                              fontFamily: TextStyle().fontFamily,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: item.percentage / 100.0,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : const Color(0xFFF0F0F0),
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
