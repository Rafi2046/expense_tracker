import 'package:flutter/material.dart';
import 'month_grid.dart';

class MonthSelectorHeader extends StatelessWidget {
  const MonthSelectorHeader({
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
    return MonthGrid(
      scrollController: scrollController,
      months: months,
      selectedIndex: selectedIndex,
      locale: locale,
      onMonthTap: onMonthTap,
    );
  }
}
