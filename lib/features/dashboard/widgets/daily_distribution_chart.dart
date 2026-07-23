import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class DailyChartData {
  final String timeLabel;
  final double value;
  final bool isHighlighted;

  DailyChartData(this.timeLabel, this.value, {this.isHighlighted = false});
}

class DailyDistributionChart extends StatelessWidget {
  final List<DailyChartData> data;

  const DailyDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distribution',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: TextStyle().fontFamily,
                ),
              ),
              Text(
                '24-Hour Period',
                style: AppTextStyles.label.copyWith(color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontFamily: TextStyle().fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFamily: TextStyle().fontFamily,
                ),
              ),
              primaryYAxis: const NumericAxis(
                isVisible: false,
                majorGridLines: MajorGridLines(width: 0),
                axisLine: AxisLine(width: 0),
              ),
              series: <CartesianSeries<DailyChartData, String>>[
                ColumnSeries<DailyChartData, String>(
                  dataSource: data,
                  xValueMapper: (DailyChartData item, _) => item.timeLabel,
                  yValueMapper: (DailyChartData item, _) => item.value,
                  pointColorMapper: (DailyChartData item, _) =>
                      item.isHighlighted
                      ? primaryColor
                      : primaryColor.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.r8),
                    topRight: Radius.circular(AppSpacing.r8),
                  ),
                  width: 0.6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
