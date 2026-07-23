import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_item.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_summary/weekly_stat_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_summary/weekly_category_tile.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_summary/weekly_segment_control.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_summary/weekly_insights_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_summary/weekly_comparison_badge.dart';
import 'package:expense_tracker/features/dashboard/widgets/weekly_summary/weekly_summary_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _ChartData {
  final String dayLabel;
  final double value;
  final bool isToday;

  _ChartData(this.dayLabel, this.value, {this.isToday = false});
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;
  int _selectedTabIndex = 0; // 0 = Category breakdown, 1 = Daily trend

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _loading = true);
    }

    final profileId =
        SharedPrefsHelper.getString(SharedPrefsHelper.activeProfileKey) ??
            'default_profile';

    final summary = await DatabaseHelper.instance
        .getPremiumWeeklySummary(profileId: profileId);

    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  String _weekRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6));
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = scheme.primary;

    final total = ((_summary?['total'] as num?)?.toDouble() ?? 0.0);
    final count = (_summary?['transactionCount'] as num?)?.toInt() ?? 0;
    final previousTotal = ((_summary?['previousTotal'] as num?)?.toDouble() ?? 0.0);

    final highestTx = _summary?['highestTransaction'] as Map<String, dynamic>?;
    final highestAmount = ((highestTx?['amount'] as num?)?.toDouble() ?? 0.0);
    final highestCategory = highestTx?['category'] as String? ?? '';

    // Calculate dynamic insights peak day label
    String highestDayLabel = '';
    if (highestTx?['dateTime'] != null) {
      final dt = DateTime.tryParse(highestTx!['dateTime'] as String);
      if (dt != null) {
        highestDayLabel = DateFormat('EEEE').format(dt);
      }
    }

    // 1. Doughnut Chart Data mapping
    final List<dynamic> catRows = _summary?['categoryBreakdown'] ?? [];
    final List<CategoryBreakdownItem> doughnutItems = [];
    for (int i = 0; i < catRows.length; i++) {
      final row = catRows[i];
      final name = (row['category'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
      if (amount <= 0) continue;
      final percentage = total > 0 ? (amount / total) : 0.0;
      doughnutItems.add(CategoryBreakdownItem(
        name: name,
        amount: amount,
        percentage: percentage,
        color: WeeklySummaryUtils.getCategoryColor(name, i),
      ));
    }

    // 2. Cartesian Chart Data mapping
    final Map<String, double> dailyMap = {};
    if (_summary?['dailyBreakdown'] != null) {
      for (final row in _summary!['dailyBreakdown']) {
        final dateStr = row['dateStr'] as String;
        final amount = (row['amount'] as num).toDouble();
        dailyMap[dateStr] = amount;
      }
    }

    final List<_ChartData> trendData = [];
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd');
    final dfLabel = DateFormat('E');

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = df.format(date);
      final val = dailyMap[dateKey] ?? 0.0;
      final label = dfLabel.format(date);
      trendData.add(_ChartData(label, val, isToday: i == 0));
    }

    // 3. Weekly insights generation
    final topCategory = doughnutItems.isNotEmpty ? doughnutItems.first.name : null;
    final topAmount = doughnutItems.isNotEmpty ? doughnutItems.first.amount : 0.0;
    final insightsList = WeeklySummaryUtils.generateInsights(
      context: context,
      total: total,
      previousTotal: previousTotal,
      topCategory: topCategory,
      topAmount: topAmount,
      highestAmount: highestAmount,
      highestDayLabel: highestDayLabel,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('weekly_summary'),
          style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? scheme.outline : scheme.surfaceContainer,
            height: 1.0,
          ),
        ),
      ),
      body: _loading
          ? _buildShimmerSkeleton(context, isDark)
          : RefreshIndicator(
              onRefresh: () => _load(showLoading: false),
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date Range subtitle card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
                    decoration: BoxDecoration(
                      color: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                      border: Border.all(
                        color: isDark ? scheme.surfaceContainerHighest : scheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          _weekRange(),
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // ── Total Spent Main Header Card ──
                  SizedBox(
                    width: double.infinity,
                    height: 130,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.p16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.r24),
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('total_spent'),
                            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600,
                              color: scheme.onPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: PrivacyMaskedText(
                              amount: total,
                              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                                color: scheme.onPrimary),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: WeeklyComparisonBadge(total: total, previousTotal: previousTotal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  // ── Highlights cards grid ──
                  Row(
                    children: [
                      Expanded(
                        child: WeeklyStatCard(
                          label: context.translate('avg_per_day'),
                          icon: LucideIcons.calculator,
                          iconColor: scheme.tertiary,
                          isDark: isDark,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: PrivacyMaskedText(
                              amount: total / 7.0,
                              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: WeeklyStatCard(
                          label: context.translate('transactions'),
                          icon: LucideIcons.receipt,
                          iconColor: scheme.secondary,
                          isDark: isDark,
                          child: Text(
                            '$count',
                            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  
                  // Prominent, full-width Highest Expense card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.p12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                      border: Border.all(
                        color: isDark ? scheme.surfaceContainerHighest : scheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.translate('peak_spike'),
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500,
                            color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        if (highestAmount > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      highestTx?['note'] as String? ?? highestCategory,
                                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (highestCategory.isNotEmpty) ...[
                                      const SizedBox(height: AppSpacing.s4),
                                      Text(
                                        highestCategory,
                                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500,
                                          color: scheme.onSurfaceVariant),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              PrivacyMaskedText(
                                amount: highestAmount,
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            '—',
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  // ── Interactive Chart Panel ──
                  if (total > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.p16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(AppSpacing.r24),
                        border: Border.all(
                          color: isDark ? scheme.surfaceContainerHighest : scheme.outlineVariant,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.onSurface.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WeeklySegmentControl(
                            selectedIndex: _selectedTabIndex,
                            onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
                            activeColor: activeColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          SizedBox(
                            height: 210,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _selectedTabIndex == 0
                                  ? SfCircularChart(
                                      margin: EdgeInsets.zero,
                                      annotations: <CircularChartAnnotation>[
                                        CircularChartAnnotation(
                                          widget: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final chartSize = constraints.maxWidth < constraints.maxHeight
                                                  ? constraints.maxWidth
                                                  : constraints.maxHeight;
                                              final innerDiameter = chartSize * 0.55;
                                              return SizedBox(
                                                width: innerDiameter,
                                                height: innerDiameter,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(AppSpacing.p4),
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            context.translate('total'),
                                                            style: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant,
                                                              fontWeight: FontWeight.w500),
                                                          ),
                                                          const SizedBox(height: AppSpacing.s4),
                                                          PrivacyMaskedText(
                                                            amount: total,
                                                            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
                                                              color: theme.colorScheme.onSurface),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      series: <CircularSeries<CategoryBreakdownItem, String>>[
                                        DoughnutSeries<CategoryBreakdownItem, String>(
                                          dataSource: doughnutItems,
                                          xValueMapper: (CategoryBreakdownItem item, _) => item.name,
                                          yValueMapper: (CategoryBreakdownItem item, _) => item.amount,
                                          pointColorMapper: (CategoryBreakdownItem item, _) => item.color,
                                          innerRadius: '75%',
                                          startAngle: 270,
                                          endAngle: 270,
                                          dataLabelSettings: const DataLabelSettings(isVisible: false),
                                          animationDuration: 800,
                                        ),
                                      ],
                                    )
                                  : SfCartesianChart(
                                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.p4, vertical: AppSpacing.p8),
                                      plotAreaBorderWidth: 0,
                                      primaryXAxis: CategoryAxis(
                                        majorGridLines: const MajorGridLines(width: 0),
                                        axisLine: const AxisLine(width: 0),
                                        labelStyle: AppTextStyles.caption.copyWith(color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500),
                                      ),
                                      primaryYAxis: const NumericAxis(
                                        isVisible: false,
                                        majorGridLines: MajorGridLines(width: 0),
                                        axisLine: AxisLine(width: 0),
                                      ),
                                      tooltipBehavior: TooltipBehavior(
                                        enable: true,
                                        header: '',
                                        canShowMarker: false,
                                        format: 'point.x: point.y',
                                      ),
                                      series: <CartesianSeries<_ChartData, String>>[
                                        ColumnSeries<_ChartData, String>(
                                          dataSource: trendData,
                                          xValueMapper: (_ChartData item, _) => item.dayLabel,
                                          yValueMapper: (_ChartData item, _) => item.value,
                                          pointColorMapper: (_ChartData item, _) =>
                                              item.isToday ? activeColor : activeColor.withValues(alpha: 0.4),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(AppSpacing.r8),
                                            topRight: Radius.circular(AppSpacing.r8),
                                          ),
                                          width: 0.45,
                                          animationDuration: 800,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // ── Category List Section ──
                    Text(
                      context.translate('distribution'),
                      style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.p16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(AppSpacing.r24),
                        border: Border.all(
                          color: isDark ? scheme.surfaceContainerHighest : scheme.outlineVariant,
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: Scrollbar(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: doughnutItems.length,
                            separatorBuilder: (ctx, idx) => Divider(
                              color: isDark ? scheme.outline : scheme.surfaceContainer,
                              height: 16,
                              thickness: 1,
                            ),
                            itemBuilder: (ctx, index) {
                              final item = doughnutItems[index];
                              final dbCount = (catRows.firstWhere(
                                (r) => (r['category'] as String?) == item.name,
                                orElse: () => {'count': 0},
                              )['count'] as num?)
                                      ?.toInt() ??
                                  0;
                              return WeeklyCategoryTile(
                                item: item,
                                count: dbCount,
                                isDark: isDark,
                                icon: WeeklySummaryUtils.getCategoryIcon(item.name),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],

                  // ── Insights Section ──
                  WeeklyInsightsCard(
                    insights: insightsList,
                    activeColor: activeColor,
                    isDark: isDark,
                  ),

                  // ── No expenses state ──
                  if (total <= 0) ...[
                    const SizedBox(height: AppSpacing.s32),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.p16),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.sparkles,
                              size: 40,
                              color: activeColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            context.translate('no_expenses_this_week'),
                            style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ),
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context, bool isDark) {
    final scheme = Theme.of(context).colorScheme;
    final shimmerColor = scheme.onSurface.withValues(alpha: isDark ? 0.06 : 0.08);
    final baseColor = scheme.surfaceContainerHighest;
    final borderColor = scheme.outline;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range card skeleton
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Two stat cards side by side
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Container(
                        width: 100,
                        height: 24,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Container(
                        width: 50,
                        height: 24,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          // Segment Control skeleton
          Container(
            width: double.infinity,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Chart / Distribution card skeleton
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        value: 0.7,
                        color: Colors.transparent,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Insights Card skeleton
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            padding: const EdgeInsets.all(AppSpacing.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.p12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(top: AppSpacing.p4),
                            decoration: BoxDecoration(
                              color: baseColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Container(
                                  width: 150,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                                  ),
                                ),
                              ],
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
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: shimmerColor);
  }
}
