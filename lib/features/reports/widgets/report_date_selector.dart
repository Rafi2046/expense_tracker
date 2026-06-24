import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDateSelector extends StatelessWidget {
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange> onRangeChanged;

  const ReportDateSelector({
    super.key,
    required this.dateRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateRangeStr = dateRange != null
        ? '${DateFormat('01 MMM yyyy').format(dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(dateRange!.end)}'
        : 'Select range';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: AppTextStyles.reportTransactionTitle,
                  ),
                  Text(
                    dateRangeStr,
                    style: AppTextStyles.reportTransactionSubtitle,
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final range = await DateRangePickerSheet.show(
                context,
                initialSelectedRange: dateRange,
              );
              if (range != null) {
                onRangeChanged(range);
              }
            },
            child: Text(
              'CHANGE',
              style: AppTextStyles.reportSectionHeader.copyWith(
                color: AppColors.activeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
