import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_trend_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dart:math' show max;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    final maxVal = data.map((d) => d.value).fold(0.0, (m, v) => v > m ? v : m);
    final double computedMax = max(10000.0, (maxVal / 5000).ceil() * 5000.0);
    final double computedInterval = computedMax / 2;

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
                context.translate('income_trend'),
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: TextStyle().fontFamily,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  LucideIcons.info,
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
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: theme.dividerTheme.color ?? const Color(0xFFF0F0F0),
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                minimum: 0,
                maximum: computedMax,
                interval: computedInterval,
                labelFormat: '{value}',
                labelStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontFamily: TextStyle().fontFamily,
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  String label = details.text;
                  if (details.value == 0) {
                    label = '0';
                  } else if (details.value >= 1000) {
                    label = '${(details.value / 1000).toStringAsFixed(0)}k';
                  }
                  return ChartAxisLabel(
                    label,
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontFamily: TextStyle().fontFamily,
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
                      ? primaryColor
                      : primaryColor.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.r8),
                    topRight: Radius.circular(AppSpacing.r8),
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
