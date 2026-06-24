import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/select_date_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportDateSelector extends StatelessWidget {
  const ReportDateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final dateRange = reportsProvider.selectedDateRange;
    final selectedOption = reportsProvider.selectedOption;

    final title = reportsProvider.getDateRangeOptionTitle(selectedOption);
    final subtitle = reportsProvider.getDateRangeSubtitle(selectedOption, dateRange);

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
                    title,
                    style: AppTextStyles.reportTransactionTitle,
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.reportTransactionSubtitle,
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final result = await SelectDateOptionSheet.show(
                context,
                currentOption: selectedOption,
              );
              if (result != null && context.mounted) {
                reportsProvider.setDateRangeOption(
                  result['option'] as DateRangeOption,
                  customRange: result['range'] as DateTimeRange?,
                );
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
