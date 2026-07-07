import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryBreakdownItem {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class ExpenseCategoriesBreakdownCard extends StatefulWidget {
  final String suffixText;
  final Widget totalAmount;
  final List<CategoryBreakdownItem> categories;
  final bool isMasked;

  const ExpenseCategoriesBreakdownCard({
    super.key,
    required this.suffixText,
    required this.totalAmount,
    required this.categories,
    required this.isMasked,
  });

  @override
  State<ExpenseCategoriesBreakdownCard> createState() =>
      _ExpenseCategoriesBreakdownCardState();
}

class _ExpenseCategoriesBreakdownCardState
    extends State<ExpenseCategoriesBreakdownCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final showExpandButton = widget.categories.length > 3;
    final displayList = (_isExpanded || !showExpandButton)
        ? widget.categories
        : widget.categories.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          // Header with gradient accent bar
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
                'Categories Breakdown',
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
              widget.suffixText,
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal: chart left, list right
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
                        series: <CircularSeries<CategoryBreakdownItem, String>>[
                          DoughnutSeries<CategoryBreakdownItem, String>(
                            dataSource: widget.categories,
                            xValueMapper: (CategoryBreakdownItem item, _) => item.name,
                            yValueMapper: (CategoryBreakdownItem item, _) => item.amount,
                            pointColorMapper: (CategoryBreakdownItem item, _) => item.color,
                            innerRadius: '70%',
                            startAngle: 270,
                            endAngle: 270,
                            dataLabelSettings: const DataLabelSettings(isVisible: false),
                            animationDuration: 1000,
                          ),
                        ],
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final chartSize =
                              constraints.maxWidth < constraints.maxHeight
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
                                        'Total',
                                        style: GoogleFonts.workSans(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      widget.totalAmount,
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
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 10,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 190),
                  child: ListView(
                    children: displayList.map((item) {
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
                                    item.name,
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

          // Expand / Collapse button
          if (showExpandButton) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isExpanded ? 'View Less' : 'View All Category',
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.activeGreen,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
