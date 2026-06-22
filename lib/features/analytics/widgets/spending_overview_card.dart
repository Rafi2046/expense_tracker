import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SpendingDistributionItem {
  final String category;
  final double percentage;
  final double amount;
  final Color color;

  SpendingDistributionItem({
    required this.category,
    required this.percentage,
    required this.amount,
    required this.color,
  });
}

class SpendingOverviewCard extends StatelessWidget {
  final String totalAmount;
  final List<SpendingDistributionItem> items;

  const SpendingOverviewCard({
    super.key,
    required this.totalAmount,
    required this.items,
  });

  Widget _buildLegendItem(String category, double percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$category ${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF31394D),
            fontFamily: GoogleFonts.workSans().fontFamily,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Split items for 2x2 legend matching screenshot layout:
    // Left column: Housing, Transport
    // Right column: Food, Utilities
    final leftColumnItems = <SpendingDistributionItem>[];
    final rightColumnItems = <SpendingDistributionItem>[];

    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        leftColumnItems.add(items[i]);
      } else {
        rightColumnItems.add(items[i]);
      }
    }

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
          // Header
          Text(
            context.translate('distribution'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.translate('current_month_distribution'),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontFamily: GoogleFonts.workSans().fontFamily,
            ),
          ),
          const SizedBox(height: 16),

          // Donut Chart inside a Stack
          Center(
            child: SizedBox(
              height: 180,
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <CircularSeries<SpendingDistributionItem, String>>[
                      DoughnutSeries<SpendingDistributionItem, String>(
                        dataSource: items,
                        xValueMapper: (SpendingDistributionItem item, _) => item.category,
                        yValueMapper: (SpendingDistributionItem item, _) => item.amount,
                        pointColorMapper: (SpendingDistributionItem item, _) => item.color,
                        innerRadius: '75%',
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
                        context.translate('total'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalAmount,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2x2 Legend Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: leftColumnItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildLegendItem(item.category, item.percentage, item.color),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rightColumnItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildLegendItem(item.category, item.percentage, item.color),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
