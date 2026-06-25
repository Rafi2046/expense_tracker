import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyChartData {
  final String dayLabel;
  final double value;
  final bool isHighlighted;

  WeeklyChartData(this.dayLabel, this.value, {this.isHighlighted = false});
}

class WeeklyTrendChart extends StatelessWidget {
  final List<WeeklyChartData> data;

  const WeeklyTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Income (${context.currencySymbol})',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  final isCurrent = details.text == 'Wed';
                  return ChartAxisLabel(
                    details.text,
                    TextStyle(
                      fontSize: 11,
                      color: isCurrent ? theme.colorScheme.onSurface : AppColors.textMuted,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  );
                },
              ),
              primaryYAxis: const NumericAxis(
                isVisible: false,
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
              ),
              series: <CartesianSeries<WeeklyChartData, String>>[
                ColumnSeries<WeeklyChartData, String>(
                  dataSource: data,
                  xValueMapper: (WeeklyChartData item, _) => item.dayLabel,
                  yValueMapper: (WeeklyChartData item, _) => item.value,
                  pointColorMapper: (WeeklyChartData item, _) =>
                      item.isHighlighted
                      ? primaryColor
                      : primaryColor.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
