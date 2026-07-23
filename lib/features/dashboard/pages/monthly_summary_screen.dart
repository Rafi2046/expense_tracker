import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/utils/database_helper.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import '../widgets/category_breakdown_item.dart';
import '../widgets/daily_summary/daily_stat_card.dart';
import '../widgets/daily_summary/daily_category_tile.dart';
import '../widgets/daily_summary/daily_insights_card.dart';
import '../widgets/daily_summary/daily_summary_utils.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class MonthlySummaryScreen extends StatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

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
        .getPremiumMonthlySummary(profileId: profileId);

    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  String _monthLabel() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor;

    final total = ((_summary?['total'] as num?)?.toDouble() ?? 0.0);
    final count = (_summary?['transactionCount'] as num?)?.toInt() ?? 0;
    final averageDaily = ((_summary?['averageDaily'] as num?)?.toDouble() ?? 0.0);

    final highestTx = _summary?['highestTransaction'] as Map<String, dynamic>?;
    final highestAmount = ((highestTx?['amount'] as num?)?.toDouble() ?? 0.0);
    final highestCategory = highestTx?['category'] as String? ?? '';

    // Doughnut Chart Data mapping
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
        color: DailySummaryUtils.getCategoryColor(name, i),
      ));
    }

    // Dynamic insights generation
    final topCategory = doughnutItems.isNotEmpty ? doughnutItems.first.name : null;
    final topAmount = doughnutItems.isNotEmpty ? doughnutItems.first.amount : 0.0;
    final insightsList = DailySummaryUtils.generateInsights(
      context: context,
      total: total,
      averageDaily: averageDaily,
      topCategory: topCategory,
      topAmount: topAmount,
      highestAmount: highestAmount,
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
          context.translate('monthly_summary'),
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
          ? _buildShimmerSkeleton(context, isDark)
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 80 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Month Card ──
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF22262E) : Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.r16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
                    child: Text(
                      _monthLabel(),
                      style: AppTextStyles.bodyBold.copyWith(
                        color: theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  if (total > 0) ...[
                    // ── Stat Cards ──
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: DailyStatCard(
                              title: context.translate('monthly_expenses'),
                              amount: total,
                              subtitle: '${context.translate('logged_this_month')}: $count',
                              gradientColors: isDark
                                  ? [const Color(0xFF22262E), const Color(0xFF1E2129)]
                                  : [Colors.white, Colors.white],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: DailyStatCard(
                              title: context.translate('daily_average'),
                              amount: averageDaily,
                              subtitle: context.translate('monthly_trend'),
                              gradientColors: isDark
                                  ? [const Color(0xFF22262E), const Color(0xFF1E2129)]
                                  : [Colors.white, Colors.white],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // ── Highest Expense Card ──
                    if (highestAmount > 0) ...[
                      DailyStatCard(
                        title: context.translate('highest_expense_this_month'),
                        amount: highestAmount,
                        subtitle: '$highestCategory${highestTx?['note'] != null && (highestTx!['note'] as String).isNotEmpty ? " (${highestTx['note']})" : ""}',
                        gradientColors: isDark
                            ? [const Color(0xFF22262E), const Color(0xFF1E2129)]
                            : [Colors.white, Colors.white],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                    ],

                    // ── Category Distribution Chart Card ──
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF22262E) : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.r16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('distribution'),
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          SizedBox(
                            height: 180,
                            child: SfCircularChart(
                              margin: EdgeInsets.zero,
                              legend: const Legend(
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                                position: LegendPosition.bottom,
                              ),
                              series: <CircularSeries>[
                                DoughnutSeries<CategoryBreakdownItem, String>(
                                  dataSource: doughnutItems,
                                  xValueMapper: (CategoryBreakdownItem data, _) => data.name,
                                  yValueMapper: (CategoryBreakdownItem data, _) => data.amount,
                                  pointColorMapper: (CategoryBreakdownItem data, _) => data.color,
                                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                                  innerRadius: '65%',
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: doughnutItems.length > 4 ? 290 : double.infinity,
                            ),
                            child: Scrollbar(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: doughnutItems.length > 4
                                    ? const ClampingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: doughnutItems.length,
                                itemBuilder: (context, index) {
                                  final item = doughnutItems[index];
                                  return DailyCategoryTile(
                                    categoryName: item.name,
                                    amount: item.amount,
                                    percentage: item.percentage,
                                    color: item.color,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ] else ...[
                    // Empty State View
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: AppSpacing.p16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF22262E) : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.r16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            context.translate('no_expenses_this_month'),
                            style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],

                  // ── Insights Card ──
                  DailyInsightsCard(insights: insightsList),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context, bool isDark) {
    final shimmerColor = isDark ? Colors.white10 : Colors.black12;
    final baseColor = isDark ? const Color(0xFF2E323E) : Colors.grey.shade200;
    final borderColor = isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Card
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22262E) : Colors.white,
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

          // Stats row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF22262E) : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 75,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Container(
                        width: 90,
                        height: 24,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        width: 55,
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
                    color: isDark ? const Color(0xFF22262E) : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.r16),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Container(
                        width: 90,
                        height: 24,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppSpacing.r8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Container(
                        width: 55,
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

          // Highest expense skeleton
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22262E) : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Distribution skeleton
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22262E) : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Insights skeleton
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22262E) : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.r16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: shimmerColor);
  }
}
