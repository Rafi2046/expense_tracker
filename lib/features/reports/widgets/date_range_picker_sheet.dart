import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/reports/widgets/select_date_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateRangePickerSheet extends StatefulWidget {
  final DateTimeRange? initialSelectedRange;

  const DateRangePickerSheet({
    super.key,
    this.initialSelectedRange,
  });

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? initialSelectedRange,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerSheet(
        initialSelectedRange: initialSelectedRange,
      ),
    );
  }

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _currentMonth;
  late DateTime _nextMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _nextMonth = DateTime(now.year, now.month + 1, 1);

    if (widget.initialSelectedRange != null) {
      _startDate = widget.initialSelectedRange!.start;
      _endDate = widget.initialSelectedRange!.end;
    } else {
      // Default to current month range
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month, now.day);
    }
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && date.isBefore(_startDate!)) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  bool _isDateSelected(DateTime date) {
    if (_startDate != null && _startDate!.year == date.year && _startDate!.month == date.month && _startDate!.day == date.day) {
      return true;
    }
    if (_endDate != null && _endDate!.year == date.year && _endDate!.month == date.month && _endDate!.day == date.day) {
      return true;
    }
    return false;
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  String get _rangeText {
    if (_startDate == null) return 'Select dates';
    final startFormat = DateFormat('MMM d').format(_startDate!);
    if (_endDate == null) return startFormat;
    final endFormat = DateFormat('MMM d').format(_endDate!);
    return '$startFormat – $endFormat';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: mediaQuery.size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Close button & title row
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 16.0, top: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Symbols.close_rounded, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Select Date',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance the close button
              ],
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // Date display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _rangeText,
                      style: GoogleFonts.workSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(Symbols.edit, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 18),
                      onPressed: () async {
                        final result = await SelectDateInputDialog.show(
                          context,
                          initialRange: DateTimeRange(
                            start: _startDate ?? DateTime.now(),
                            end: _endDate ?? DateTime.now(),
                          ),
                        );
                        if (result != null && context.mounted) {
                          setState(() {
                            _startDate = result.range.start;
                            _endDate = result.range.end;
                          });
                          if (result.shouldSubmit) {
                            Navigator.pop(context, result.range);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // S M T W T F S weekday headings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.workSans(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable calendar content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildMonthCalendar(_currentMonth),
                  const SizedBox(height: 24),
                  _buildMonthCalendar(_nextMonth),
                ],
              ),
            ),
          ),

          Divider(color: theme.dividerColor, height: 1),

          // Bottom Cancel / Ok Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.workSans(
                      color: AppColors.activeGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _startDate == null || _endDate == null
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            DateTimeRange(start: _startDate!, end: _endDate!),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  ),
                  child: Text(
                    'Ok',
                    style: GoogleFonts.workSans(
                      color: _startDate == null || _endDate == null
                          ? (isDark ? Colors.white24 : Colors.grey.shade400)
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final year = month.year;
    final monthNumber = month.month;
    final monthName = DateFormat('MMMM yyyy').format(month);

    final daysInMonth = DateTime(year, monthNumber + 1, 0).day;
    final firstDayOfWeek = DateTime(year, monthNumber, 1).weekday % 7; // Sunday = 0

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            monthName,
            style: GoogleFonts.workSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
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
              // Handle border radiuses for ranges
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
              onTap: () => _onDateTap(date),
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
                        style: GoogleFonts.workSans(
                          color: isSelected
                              ? Colors.white
                              : (isInRange
                                  ? AppColors.activeGreen
                                  : theme.colorScheme.onSurface),
                          fontWeight:
                              isSelected || isInRange ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
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
