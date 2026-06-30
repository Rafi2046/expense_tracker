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
  final Widget totalAmount;
  final List<SpendingDistributionItem> items;

  const SpendingOverviewCard({
    super.key,
    required this.totalAmount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A53A1), Color(0xFF32235B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.translate('distribution'),
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              context.translate('current_month_distribution'),
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 11,
                child: SizedBox(
                  height: 190,
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
                            innerRadius: '70%',
                            startAngle: 270,
                            endAngle: 270,
                            dataLabelSettings: const DataLabelSettings(isVisible: false),
                            animationDuration: 1000,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.translate('total'),
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                totalAmount,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 10,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 190),
                  child: ListView(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.category,
                                    style: GoogleFonts.workSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: item.percentage / 100,
                                      backgroundColor: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFFF0F0F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.percentage < 1
                                  ? '${item.percentage.toStringAsFixed(1)}%'
                                  : '${item.percentage.toStringAsFixed(0)}%',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
