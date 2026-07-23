import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



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
                context.translate('seven_day_trend'),
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: TextStyle().fontFamily,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(AppSpacing.r8),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Income (${context.currencySymbol})',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                      fontFamily: TextStyle().fontFamily,
                    ),
                  ),
                ],
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
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final currentLabel = weekdayLabels[DateTime.now().weekday - 1];
                  final isCurrent = details.text == currentLabel;
                  return ChartAxisLabel(
                    details.text,
                    AppTextStyles.caption.copyWith(color: isCurrent ? theme.colorScheme.onSurface : AppColors.textMuted,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      fontFamily: TextStyle().fontFamily,
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
                    topLeft: Radius.circular(AppSpacing.r8),
                    topRight: Radius.circular(AppSpacing.r8),
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
