import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_picker_sheet.dart';

class SelectDateOptionSheet extends StatelessWidget {
  final DateRangeOption currentOption;

  const SelectDateOptionSheet({
    super.key,
    required this.currentOption,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required DateRangeOption currentOption,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: SelectDateOptionSheet(currentOption: currentOption),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Select Date',
              style: AppTextStyles.dialogTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F1F1)),
          ...DateRangeOption.values.map((option) {
            return _buildOption(
              context: context,
              reportsProvider: reportsProvider,
              option: option,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required ReportsProvider reportsProvider,
    required DateRangeOption option,
  }) {
    final isSelected = currentOption == option;
    final title = reportsProvider.getDateRangeOptionTitle(option);
    final subtitle = reportsProvider.getDateRangeSubtitle(option, null);

    return InkWell(
      onTap: () async {
        if (option == DateRangeOption.custom) {
          final currentRange = reportsProvider.selectedDateRange;
          final range = await DateRangePickerSheet.show(
            context,
            initialSelectedRange: currentRange,
          );
          if (range != null && context.mounted) {
            Navigator.pop(context, {
              'option': DateRangeOption.custom,
              'range': range,
            });
          }
        } else {
          Navigator.pop(context, {
            'option': option,
            'range': reportsProvider.getDateTimeRangeForOption(option),
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.black87 : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.reportTransactionSubtitle.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.activeGreen : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.activeGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
