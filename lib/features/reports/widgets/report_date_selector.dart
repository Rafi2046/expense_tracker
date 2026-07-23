import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/select_date_option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportDateSelector extends StatelessWidget {
  const ReportDateSelector({super.key});

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
    final dateRange = reportsProvider.selectedDateRange;
    final selectedOption = reportsProvider.selectedOption;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = reportsProvider.getDateRangeOptionTitle(selectedOption);
    final subtitle = reportsProvider.getDateRangeSubtitle(selectedOption, dateRange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calendar, color: isDark ? Colors.white60 : Colors.grey.shade600, size: AppSpacing.s16),
              const SizedBox(width: AppSpacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translateTitle(context, title),
                    style: AppTextStyles.bodyBold.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  Text(
                    _translateSubtitle(context, subtitle),
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
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
              context.translate('change'),
              style: AppTextStyles.caption.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
