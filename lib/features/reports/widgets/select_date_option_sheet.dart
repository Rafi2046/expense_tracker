import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/date_range_picker_sheet.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
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

  String _translateTitle(BuildContext context, String title) {
    final key = title.toLowerCase().replaceAll(' ', '_');
    return context.translate(key);
  }

  String _translateSubtitle(BuildContext context, String subtitle) {
    if (subtitle == 'See Transactions of all time') {
      return context.translate('see_transactions_of_all_time');
    }
    if (subtitle == 'Select date from calendar') {
      return context.translate('select_date_from_calendar');
    }
    if (subtitle == 'Select range') {
      return context.translate('select_range');
    }
    return subtitle;
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
            margin: const EdgeInsets.only(top: AppSpacing.p8, bottom: AppSpacing.p8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
          child: Text(
            context.translate('select_date'),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translateTitle(context, title),
                    style: AppTextStyles.bodyBold.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    _translateSubtitle(context, subtitle),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
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
