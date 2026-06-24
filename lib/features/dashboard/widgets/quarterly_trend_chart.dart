import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class QuarterlyChartData {
  final String monthLabel;
  final double value;
  final bool isHighlighted;

  QuarterlyChartData(this.monthLabel, this.value, {this.isHighlighted = false});
}

class QuarterlyTrendChart extends StatelessWidget {
  final List<QuarterlyChartData> data;

  const QuarterlyTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income Trend (Q3)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.activeGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Actuals',
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
                  final isCurrent = details.text == 'SEP';
                  return ChartAxisLabel(
                    details.text,
                    TextStyle(
                      fontSize: 11,
                      color: isCurrent ? Colors.black : AppColors.textMuted,
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
              series: <CartesianSeries<QuarterlyChartData, String>>[
                ColumnSeries<QuarterlyChartData, String>(
                  dataSource: data,
                  xValueMapper: (QuarterlyChartData item, _) => item.monthLabel,
                  yValueMapper: (QuarterlyChartData item, _) => item.value,
                  pointColorMapper: (QuarterlyChartData item, _) =>
                      item.isHighlighted
                      ? AppColors.activeGreen
                      : AppColors.activeGreen.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
