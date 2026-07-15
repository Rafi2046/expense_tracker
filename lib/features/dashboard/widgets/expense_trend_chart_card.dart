import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExpenseChartData {
  final String label;
  final double value;
  final bool isHighlighted;

  ExpenseChartData(this.label, this.value, {this.isHighlighted = false});
}

class ExpenseTrendChartCard extends StatelessWidget {
  final String timeFrame;
  final String? title;
  final Widget? amount;
  final String? trendPercentage;
  final List<ExpenseChartData> chartData;

  const ExpenseTrendChartCard({
    super.key,
    required this.timeFrame,
    this.title,
    this.amount,
    this.trendPercentage,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showHeader = title != null || amount != null || trendPercentage != null;

    // Configure Y-Axis based on selected timeframe
    double minimum = 0;
    double maximum = 1000;
    double interval = 200;

    switch (timeFrame) {
      case 'Daily':
        maximum = 800;
        interval = 200;
        break;
      case 'Weekly':
        maximum = 15000;
        interval = 5000;
        break;
      case 'Monthly':
        maximum = 25000;
        interval = 5000;
        break;
      case 'Quarterly':
        maximum = 15000;
        interval = 5000;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
          if (showHeader) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: AppFontSizes.size13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                            fontFamily: TextStyle().fontFamily,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (amount != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: amount!,
                        ),
                    ],
                  ),
                ),
                if (trendPercentage != null) ...[
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.arrowDown,
                        color: AppColors.expensePink,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendPercentage!,
                        style: TextStyle(
                          fontSize: AppFontSizes.size13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expensePink,
                          fontFamily: TextStyle().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelRotation: -45,
                labelStyle: TextStyle(
                  fontSize: AppFontSizes.size10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFamily: TextStyle().fontFamily,
                ),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: theme.dividerTheme.color ?? const Color(0xFFEEEEEE),
                  dashArray: const <double>[4, 4],
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                minimum: minimum,
                maximum: maximum,
                interval: interval,
                labelStyle: TextStyle(
                  fontSize: AppFontSizes.size11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontFamily: TextStyle().fontFamily,
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  String labelText = details.text;
                  double val = details.value.toDouble();
                  if (val == 0) {
                    labelText = '0';
                  } else if (val >= 1000) {
                    labelText = '${(val / 1000).toStringAsFixed(0)}K';
                  }
                  return ChartAxisLabel(
                    labelText,
                    TextStyle(
                      fontSize: AppFontSizes.size11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  );
                },
              ),
              series: <CartesianSeries<ExpenseChartData, String>>[
                ColumnSeries<ExpenseChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ExpenseChartData item, _) => item.label,
                  yValueMapper: (ExpenseChartData item, _) => item.value,
                  pointColorMapper: (ExpenseChartData item, _) =>
                      item.isHighlighted
                      ? AppColors.expensePink
                      : AppColors.expensePink.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                  width: 0.15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
