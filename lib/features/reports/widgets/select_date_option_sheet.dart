import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_picker_sheet.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

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
    final theme = Theme.of(context);
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: theme.cardColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Text(
            'Select Date',
            style: AppTextStyles.h3.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Divider(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),
        ...DateRangeOption.values.map((option) {
          return _buildOption(
            context: context,
            reportsProvider: reportsProvider,
            option: option,
          );
        }),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required ReportsProvider reportsProvider,
    required DateRangeOption option,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.reportTileTitle.copyWith(
                      fontSize: AppFontSizes.size14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.reportTransactionSubtitle.copyWith(
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                      fontSize: AppFontSizes.size11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.primaryColor : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
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
