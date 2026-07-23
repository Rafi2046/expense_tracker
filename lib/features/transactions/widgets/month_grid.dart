import 'package:flutter/material.dart';
import 'month_cell.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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
    return SizedBox(height: AppSpacing.s48,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(left: AppSpacing.p16, right: AppSpacing.p32),
        itemCount: months.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = index == selectedIndex;
          final isCurrent = index == 6;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
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
