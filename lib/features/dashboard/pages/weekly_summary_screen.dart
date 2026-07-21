import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
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

  Future<void> _load() async {
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
    final start = now.subtract(const Duration(days: 6));
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(start)} - ${fmt.format(now)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor;

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
      final name = row['category'] as String;
      final amount = (row['amount'] as num).toDouble();
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
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: activeColor,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date Range subtitle card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E222B) : Colors.grey.shade50.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          _weekRange(),
                          style: TextStyle(
                            fontSize: AppFontSizes.size12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Total Spent Main Header Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                            : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : const Color(0xFF6366F1))
                              .withValues(alpha: isDark ? 0.3 : 0.2),
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
                          style: TextStyle(
                            fontSize: AppFontSizes.size12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PrivacyMaskedText(
                              amount: total,
                              style: TextStyle(
                                fontSize: AppFontSizes.size32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            WeeklyComparisonBadge(total: total, previousTotal: previousTotal),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Highlights cards grid ──
                  Row(
                    children: [
                      Expanded(
                        child: WeeklyStatCard(
                          label: context.translate('avg_per_day'),
                          icon: LucideIcons.calculator,
                          iconColor: const Color(0xFF3B82F6),
                          isDark: isDark,
                          child: PrivacyMaskedText(
                            amount: total / 7.0,
                            style: TextStyle(
                              fontSize: AppFontSizes.size14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: WeeklyStatCard(
                          label: context.translate('transactions'),
                          icon: LucideIcons.receipt,
                          iconColor: const Color(0xFF2EBD85),
                          isDark: isDark,
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: AppFontSizes.size14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Prominent, full-width Highest Expense card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.arrowUpRight, color: Color(0xFFF59E0B), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.translate('peak_spike'),
                                style: TextStyle(
                                  fontSize: AppFontSizes.size10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (highestAmount > 0) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        highestTx?['note'] as String? ?? highestCategory,
                                        style: TextStyle(
                                          fontSize: AppFontSizes.size13,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PrivacyMaskedText(
                                      amount: highestAmount,
                                      style: TextStyle(
                                        fontSize: AppFontSizes.size14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text(
                                  '—',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.size13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Interactive Chart Panel ──
                  if (total > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 210,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _selectedTabIndex == 0
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SfCircularChart(
                                          margin: EdgeInsets.zero,
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
                                        ),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                context.translate('total'),
                                                style: TextStyle(
                                                  fontSize: AppFontSizes.size10,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              PrivacyMaskedText(
                                                amount: total,
                                                style: TextStyle(
                                                  fontSize: AppFontSizes.size18,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : SfCartesianChart(
                                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                      plotAreaBorderWidth: 0,
                                      primaryXAxis: CategoryAxis(
                                        majorGridLines: const MajorGridLines(width: 0),
                                        axisLine: const AxisLine(width: 0),
                                        labelStyle: TextStyle(
                                          fontSize: AppFontSizes.size10,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
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
                    const SizedBox(height: 20),

                    // ── Category List Section ──
                    Text(
                      context.translate('distribution'),
                      style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2D323F) : Colors.grey.shade200,
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
                              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
                              height: 16,
                              thickness: 1,
                            ),
                            itemBuilder: (ctx, index) {
                              final item = doughnutItems[index];
                              final dbCount = catRows.firstWhere(
                                (r) => (r['category'] as String) == item.name,
                                orElse: () => {'count': 0},
                              )['count'] as int;
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
                    const SizedBox(height: 20),
                  ],

                  // ── Insights Section ──
                  WeeklyInsightsCard(
                    insights: insightsList,
                    activeColor: activeColor,
                    isDark: isDark,
                  ),

                  // ── No expenses state ──
                  if (total <= 0) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
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
                          const SizedBox(height: 16),
                          Text(
                            context.translate('no_expenses_this_week'),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: AppFontSizes.size14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
