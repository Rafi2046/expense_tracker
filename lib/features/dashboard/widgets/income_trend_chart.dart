import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_trend_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  final String month;
  final double value;
  final bool isCurrent;

  ChartData(this.month, this.value, {this.isCurrent = false});
}

class IncomeTrendChart extends StatelessWidget {
  final List<ChartData> data;

  const IncomeTrendChart({super.key, required this.data});

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
                'Income Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const IncomeTrendInfoDialog(),
                  );
                },
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
                labelStyle: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: Color(0xFFF0F0F0),
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                minimum: 0,
                maximum: 10000,
                interval: 5000,
                labelFormat: '{value}',
                labelStyle: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFamily: GoogleFonts.workSans().fontFamily,
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  String label = details.text;
                  if (details.value == 0) {
                    label = '0';
                  } else if (details.value == 5000) {
                    label = '5k';
                  } else if (details.value == 10000) {
                    label = '10k';
                  }
                  return ChartAxisLabel(
                    label,
                    TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  );
                },
              ),
              series: <CartesianSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData item, _) => item.month,
                  yValueMapper: (ChartData item, _) => item.value,
                  pointColorMapper: (ChartData item, _) => item.isCurrent
                      ? AppColors.buttonColor
                      : AppColors.activeGreen.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
