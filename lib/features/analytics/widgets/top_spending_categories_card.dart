import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/analytics/widgets/analytics_empty_state.dart';
import 'package:expense_tracker/features/analytics/widgets/top_spending_category_row.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TopSpendingCategoriesCard extends StatelessWidget {
  final List<TopSpendingCategoryItem> items;
  final bool isMasked;

  const TopSpendingCategoriesCard({
    super.key,
    required this.items,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const AnalyticsEmptyState();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final maxAmount = items.fold(0.0, (max, item) => item.amount > max ? item.amount : max);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFE24361)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                context.translate('top_spending_categories'),
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF0F0F0),
              height: 1,
              indent: 50,
              endIndent: 0,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return TopSpendingCategoryRow(
                item: item,
                isMasked: isMasked,
                maxAmount: maxAmount,
                index: i,
              );
            },
          ),
        ],
      ),
    );
  }
}
