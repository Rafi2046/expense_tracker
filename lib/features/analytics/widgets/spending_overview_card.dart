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

  Widget _buildLegendItem(BuildContext context, String category, double percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$category ${percentage.toStringAsFixed(0)}%',
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : const Color(0xFF4A5568),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Split items for 2x2 legend
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
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            context.translate('distribution'),
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.translate('current_month_distribution'),
            style: GoogleFonts.workSans(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),

          // Donut Chart
          Center(
            child: SizedBox(
              height: 160,
              width: 160,
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
                  Container(
                    width: 100,
                    height: 80,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.translate('total'),
                            style: GoogleFonts.workSans(
                              fontSize: 10.5,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            totalAmount,
                            style: GoogleFonts.workSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2x2 Legend Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: leftColumnItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildLegendItem(context, item.category, item.percentage, item.color),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rightColumnItems
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildLegendItem(context, item.category, item.percentage, item.color),
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
