import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/analytics/widgets/top_spending_category_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopSpendingCategoriesCard extends StatelessWidget {
  final List<TopSpendingCategoryItem> items;

  const TopSpendingCategoriesCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            context.translate('top_spending_categories'),
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.translate('highest_expenditure_areas'),
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),

          // Categories List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
              height: 1,
              indent: 48,
              endIndent: 0,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return TopSpendingCategoryRow(item: item);
            },
          ),
        ],
      ),
    );
  }
}
