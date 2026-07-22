import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/utils/tour_insights_data.dart';
import 'package:expense_tracker/features/tours/widgets/tour_category_distribution.dart';
import 'package:expense_tracker/features/tours/widgets/tour_insights_toggle.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_distribution.dart';
import 'package:flutter/material.dart';

class TourInsightsCard extends StatefulWidget {
  final TourInsightsData? insights;
  final String currency;
  final bool isLoading;

  const TourInsightsCard({
    super.key,
    required this.insights,
    required this.currency,
    this.isLoading = false,
  });

  @override
  State<TourInsightsCard> createState() => _TourInsightsCardState();
}

class _TourInsightsCardState extends State<TourInsightsCard> {
  bool _isCategoryView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TourInsightsToggle(
            isCategory: _isCategoryView,
            onChanged: (val) => setState(() => _isCategoryView = val),
          ),
          const SizedBox(height: 16),
          _buildContent(isDark, theme),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, ThemeData theme) {
    if (widget.isLoading) {
      return _buildShimmer(isDark);
    }

    final data = widget.insights;
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.translate('add_expenses_to_see_breakdown'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSizes.size12,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _isCategoryView
          ? TourCategoryDistribution(
              key: const ValueKey('category'),
              items: data.categoryBreakdown,
              grandTotal: data.grandTotal,
              currency: widget.currency,
              isEmpty: data.categoryBreakdown.isEmpty,
            )
          : TourMemberDistribution(
              key: const ValueKey('member'),
              items: data.memberBreakdown,
              grandTotal: data.grandTotal,
              currency: widget.currency,
              isEmpty: data.memberBreakdown.isEmpty,
            ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final base = isDark ? const Color(0xFF2E323E) : Colors.grey.shade200;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: base, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 13,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Container(
                  width: 40, height: 11,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60, height: 13,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
