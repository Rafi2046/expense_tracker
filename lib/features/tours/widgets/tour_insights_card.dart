import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/utils/tour_insights_data.dart';
import 'package:expense_tracker/features/tours/widgets/tour_category_distribution.dart';
import 'package:expense_tracker/features/tours/widgets/tour_insights_toggle.dart';
import 'package:expense_tracker/features/tours/widgets/tour_member_distribution.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

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
  /// Progress bar + gap above rows.
  static const _headerHeight = AppSpacing.s12 + AppSpacing.s16;

  /// Dot/text row + bottom padding (`p16`).
  static const _rowHeight = 20.0 + AppSpacing.p16;

  static const _emptyHeight = 96.0;
  static const _shimmerHeight = 168.0;
  static const _heightBuffer = AppSpacing.s8;

  late final PageController _pageController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
  }

  double _pageHeight() {
    if (widget.isLoading) return _shimmerHeight;
    final data = widget.insights;
    if (data == null) return _emptyHeight;

    final catRows = data.categoryBreakdown.isEmpty
        ? 1
        : data.categoryBreakdown.length;
    final memRows =
        data.memberBreakdown.isEmpty ? 1 : data.memberBreakdown.length;
    final rows = catRows > memRows ? catRows : memRows;
    return _headerHeight + (rows * _rowHeight) + _heightBuffer;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TourInsightsToggle(
            selectedIndex: _tabIndex,
            onChanged: _onTabChanged,
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: _pageHeight(),
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildCategoryPage(isDark),
                _buildMemberPage(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPage(bool isDark) {
    if (widget.isLoading) return _buildShimmer(isDark);
    final data = widget.insights;
    if (data == null) return _buildEmpty(isDark);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: TourCategoryDistribution(
        items: data.categoryBreakdown,
        grandTotal: data.grandTotal,
        currency: widget.currency,
        isEmpty: data.categoryBreakdown.isEmpty,
      ),
    );
  }

  Widget _buildMemberPage(bool isDark) {
    if (widget.isLoading) return _buildShimmer(isDark);
    final data = widget.insights;
    if (data == null) return _buildEmpty(isDark);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: TourMemberDistribution(
        items: data.memberBreakdown,
        grandTotal: data.grandTotal,
        currency: widget.currency,
        isEmpty: data.memberBreakdown.isEmpty,
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p24),
      child: Center(
        child: Text(
          context.translate('add_expenses_to_see_breakdown'),
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    final base = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.grey.shade200;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
      child: Column(
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(AppSpacing.r8),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ...List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.p16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: base,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Container(
                      height: 13,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(AppSpacing.r8),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 11,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(AppSpacing.r8),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Container(
                    width: 60,
                    height: 13,
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: BorderRadius.circular(AppSpacing.r8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
