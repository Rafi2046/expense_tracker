import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onDateTap;

  const MonthCalendar({
    super.key,
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.onDateTap,
  });

  bool _isDateSelected(DateTime date) {
    if (startDate != null &&
        startDate!.year == date.year &&
        startDate!.month == date.month &&
        startDate!.day == date.day) {
      return true;
    }
    if (endDate != null &&
        endDate!.year == date.year &&
        endDate!.month == date.month &&
        endDate!.day == date.day) {
      return true;
    }
    return false;
  }

  bool _isDateInRange(DateTime date) {
    if (startDate == null || endDate == null) return false;
    return date.isAfter(startDate!) && date.isBefore(endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final year = month.year;
    final monthNumber = month.month;
    final monthName = DateFormat('MMMM yyyy').format(month);

    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;
    final firstDayOfWeek = DateTime(year, monthNumber, 1).weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            monthName,
            style: AppTextStyles.reportTransactionTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 0,
          ),
          itemCount: daysInMonth + firstDayOfWeek,
          itemBuilder: (context, index) {
            if (index < firstDayOfWeek) {
              return const SizedBox.shrink();
            }

            final day = index - firstDayOfWeek + 1;
            final date = DateTime(year, monthNumber, day);
            final isSelected = _isDateSelected(date);
            final isInRange = _isDateInRange(date);

            Color? boxColor;
            BorderRadius? rangeBorderRadius;

            if (isSelected) {
              boxColor = AppColors.activeGreen;
            } else if (isInRange) {
              boxColor = isDark ? AppColors.activeGreen.withValues(alpha: 0.15) : const Color(0xFFE8F8F5);
              if (date.weekday == DateTime.sunday) {
                rangeBorderRadius = const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                );
              } else if (date.weekday == DateTime.saturday) {
                rangeBorderRadius = const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                );
              }
            }

            return GestureDetector(
              onTap: () => onDateTap(date),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  color: isInRange ? (isDark ? AppColors.activeGreen.withValues(alpha: 0.15) : const Color(0xFFE8F8F5)) : null,
                  borderRadius: rangeBorderRadius,
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: boxColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isInRange
                                  ? AppColors.activeGreen
                                  : theme.colorScheme.onSurface),
                          fontWeight:
                              isSelected || isInRange ? FontWeight.bold : FontWeight.w500,
                          fontSize: AppFontSizes.size14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
