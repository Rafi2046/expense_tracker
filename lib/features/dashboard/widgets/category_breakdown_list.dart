import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_item.dart';

class CategoryBreakdownList extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;
  final bool isDark;
  final Color onSurface;

  const CategoryBreakdownList({
    super.key,
    required this.categories,
    required this.isDark,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 10,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 190),
        child: ListView(
          children: categories.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (() {
                            final lowerName = item.name.toLowerCase();
                            return (lowerName == 'food' ||
                                    lowerName == 'transport' ||
                                    lowerName == 'medicine' ||
                                    lowerName == 'rent' ||
                                    lowerName == 'entertainment' ||
                                    lowerName == 'shopping' ||
                                    lowerName == 'utilities' ||
                                    lowerName == 'salary' ||
                                    lowerName == 'freelance' ||
                                    lowerName == 'investment')
                                ? context.translate(lowerName)
                                : item.name;
                          })(),
                          style: TextStyle(
                            fontSize: AppFontSizes.size11,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: item.percentage / 100,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFF0F0F0),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(item.color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.percentage < 1
                        ? '${item.percentage.toStringAsFixed(1)}%'
                        : '${item.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: AppFontSizes.size11,
                      fontWeight: FontWeight.w700,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
