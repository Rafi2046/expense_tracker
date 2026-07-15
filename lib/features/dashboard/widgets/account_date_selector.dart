import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/select_date_option_sheet.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AccountDateSelector extends StatelessWidget {
  final DateRangeOption selectedOption;
  final DateTimeRange? selectedDateRange;
  final Function(DateRangeOption option, DateTimeRange? range) onDateSelected;

  const AccountDateSelector({
    super.key,
    required this.selectedOption,
    required this.selectedDateRange,
    required this.onDateSelected,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final result = await SelectDateOptionSheet.show(
      context,
      currentOption: selectedOption,
    );
    if (result != null) {
      onDateSelected(
        result['option'] as DateRangeOption,
        result['range'] as DateTimeRange?,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportsProvider = context.read<ReportsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : const Color(0xFFF3F4F6),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.calendar,
            size: 14,
            color: isDark ? Colors.white60 : const Color(0xFF565E74),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reportsProvider.getDateRangeOptionTitle(selectedOption),
                  style: TextStyle(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  reportsProvider.getDateRangeSubtitle(selectedOption, selectedDateRange),
                  style: TextStyle(
                    fontSize: AppFontSizes.size10,
                    color: isDark ? Colors.white60 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectDateRange(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'CHANGE',
              style: TextStyle(
                fontSize: AppFontSizes.size11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2EBD85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
