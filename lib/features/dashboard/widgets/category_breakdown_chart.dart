import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/features/dashboard/widgets/category_breakdown_item.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final List<CategoryBreakdownItem> categories;
  final Widget totalAmount;

  const CategoryBreakdownChart({
    super.key,
    required this.categories,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 11,
      child: SizedBox(
        height: 190,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SfCircularChart(
              margin: EdgeInsets.zero,
              series: <CircularSeries<CategoryBreakdownItem, String>>[
                DoughnutSeries<CategoryBreakdownItem, String>(
                  dataSource: categories,
                  xValueMapper: (CategoryBreakdownItem item, _) => item.name,
                  yValueMapper: (CategoryBreakdownItem item, _) => item.amount,
                  pointColorMapper: (CategoryBreakdownItem item, _) =>
                      item.color,
                  innerRadius: '70%',
                  startAngle: 270,
                  endAngle: 270,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: false,
                  ),
                  animationDuration: 1000,
                ),
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                final innerDiameter = chartSize * 0.55;
                return SizedBox(
                  width: innerDiameter,
                  height: innerDiameter,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.translate('total'),
                              style: TextStyle(
                                fontSize: AppFontSizes.size11,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
