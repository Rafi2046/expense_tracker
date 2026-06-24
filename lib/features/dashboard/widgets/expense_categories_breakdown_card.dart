import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryBreakdownItem {
  final String name;
  final double amount;
  final Color color;

  CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.color,
  });
}

class ExpenseCategoriesBreakdownCard extends StatefulWidget {
  final String suffixText;
  final String totalAmount;
  final List<CategoryBreakdownItem> categories;

  const ExpenseCategoriesBreakdownCard({
    super.key,
    required this.suffixText,
    required this.totalAmount,
    required this.categories,
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

    // Determine how many items to show
    final showExpandButton = widget.categories.length > 3;
    final displayList = (_isExpanded || !showExpandButton)
        ? widget.categories
        : widget.categories.take(3).toList();

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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: GoogleFonts.workSans().fontFamily,
              ),
              children: [
                const TextSpan(text: 'Categories Breakdown '),
                TextSpan(
                  text: widget.suffixText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Donut chart with total amount in the center
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <CircularSeries<CategoryBreakdownItem, String>>[
                      DoughnutSeries<CategoryBreakdownItem, String>(
                        dataSource: widget.categories,
                        xValueMapper: (CategoryBreakdownItem item, _) =>
                            item.name,
                        yValueMapper: (CategoryBreakdownItem item, _) =>
                            item.amount,
                        pointColorMapper: (CategoryBreakdownItem item, _) =>
                            item.color,
                        innerRadius: '75%',
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
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.totalAmount,
                        style: TextStyle(
                          fontSize: 18,
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
          const SizedBox(height: 24),

          // Category list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = displayList[index];
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontFamily: GoogleFonts.workSans().fontFamily,
                      ),
                    ),
                  ),
                  Text(
                    '${context.currencySymbol} ${item.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: GoogleFonts.workSans().fontFamily,
                    ),
                  ),
                ],
              );
            },
          ),

          // Expand / Collapse button
          if (showExpandButton) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isExpanded ? 'View Less' : 'View All Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.activeGreen,
                    fontFamily: GoogleFonts.workSans().fontFamily,
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
