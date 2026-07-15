import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/reports/widgets/select_date_input_dialog.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_header.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_display.dart';
import 'package:expense_tracker/features/reports/widgets/weekday_headings.dart';
import 'package:expense_tracker/features/reports/widgets/month_calendar.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_actions.dart';

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

  String get _rangeText {
    if (_startDate == null) return '';
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
          DateRangeHeader(onClose: () => Navigator.pop(context)),
          DateRangeDisplay(
            rangeText: _rangeText.isNotEmpty ? _rangeText : context.translate('select_dates'),
            onEditTap: () async {
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
          const WeekdayHeadings(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  MonthCalendar(
                    month: _currentMonth,
                    startDate: _startDate,
                    endDate: _endDate,
                    onDateTap: _onDateTap,
                  ),
                  const SizedBox(height: 24),
                  MonthCalendar(
                    month: _nextMonth,
                    startDate: _startDate,
                    endDate: _endDate,
                    onDateTap: _onDateTap,
                  ),
                ],
              ),
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),
          DateRangeActions(
            onCancel: () => Navigator.pop(context),
            onApply: _startDate != null && _endDate != null
                ? () => Navigator.pop(
                      context,
                      DateTimeRange(start: _startDate!, end: _endDate!),
                    )
                : null,
            canApply: _startDate != null && _endDate != null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
