import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class _DonutItem {
  final String label;
  final double value;
  final Color color;

  _DonutItem(this.label, this.value, this.color);
}

class DashboardSpendingCategories extends StatelessWidget {
  final String categoryName;
  final double percentage;

  const DashboardSpendingCategories({
    super.key,
    required this.categoryName,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingColor = isDark ? AppTheme.brandPrimaryLight : const Color(0xFFC6F4DF);
    
    final List<_DonutItem> chartData = [
      _DonutItem('Active', percentage, AppColors.activeGreen),
      _DonutItem('Remaining', 100 - percentage, remainingColor),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, AppSpacing.p16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? AppColors.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Label
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.p4, bottom: AppSpacing.p8),
            child: Text(
              context.translate('top_spending_categories').toUpperCase(),
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold,
                color: isDark ? Colors.white60 : AppColors.loginSubTitle.withValues(alpha: 0.8),
                fontFamily: TextStyle().fontFamily,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Donut Chart Centered
          Center(
            child: SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <CircularSeries<_DonutItem, String>>[
                      DoughnutSeries<_DonutItem, String>(
                        dataSource: chartData,
                        xValueMapper: (_DonutItem item, _) => item.label,
                        yValueMapper: (_DonutItem item, _) => item.value,
                        pointColorMapper: (_DonutItem item, _) => item.color,
                        innerRadius: '78%',
                        startAngle: 270,
                        endAngle: 270,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: false,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: TextStyle().fontFamily,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        context.translate(categoryName.toLowerCase()),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontFamily: TextStyle().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
