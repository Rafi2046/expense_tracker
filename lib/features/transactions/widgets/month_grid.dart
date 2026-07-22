import 'package:flutter/material.dart';
import 'month_cell.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.scrollController,
    required this.months,
    required this.selectedIndex,
    required this.locale,
    required this.onMonthTap,
  });

  final ScrollController scrollController;
  final List<DateTime> months;
  final int selectedIndex;
  final String locale;
  final ValueChanged<int> onMonthTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(left: 16.0, right: 32.0),
        itemCount: months.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = index == selectedIndex;
          final isCurrent = index == 6;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MonthCell(
              month: month,
              isSelected: isSelected,
              isCurrent: isCurrent,
              onTap: () => onMonthTap(index),
              locale: locale,
            ),
          );
        },
      ),
    );
  }
}
