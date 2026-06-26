import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/select_date_option_sheet.dart';

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
    final reportsProvider = context.read<ReportsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          const Icon(Symbols.calendar_today, size: 14, color: Color(0xFF565E74)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reportsProvider.getDateRangeOptionTitle(selectedOption),
                  style: GoogleFonts.workSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  reportsProvider.getDateRangeSubtitle(selectedOption, selectedDateRange),
                  style: GoogleFonts.workSans(
                    fontSize: 10.5,
                    color: Colors.grey.shade500,
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
              style: GoogleFonts.workSans(
                fontSize: 11,
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
