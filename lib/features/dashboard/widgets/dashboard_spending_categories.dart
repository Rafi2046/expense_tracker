import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    final List<_DonutItem> chartData = [
      _DonutItem('Active', percentage, AppColors.activeGreen),
      _DonutItem('Remaining', 100 - percentage, const Color(0xFFC6F4DF)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
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
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              'SPENDING CATEGORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.loginSubTitle.withValues(alpha: 0.8),
                fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
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
                        dataLabelSettings: const DataLabelSettings(isVisible: false),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoryName,
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
            ),
          ),
        ],
      ),
    );
  }
}
