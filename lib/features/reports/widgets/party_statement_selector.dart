import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_select_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementSelector extends StatelessWidget {
  const PartyStatementSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final isSelected = partyName != null;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () async {
          final selected = await PartySelectSheet.show(
            context,
            selectedPartyName: partyName,
          );
          if (selected != null) {
            reportsProvider.setStatementParty(
              selected == 'clear_selection' ? null : selected,
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.activeGreen : const Color(0xFFF1F2F4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                partyName ?? 'Select Party',
                style: AppTextStyles.reportTileTitle.copyWith(
                  fontSize: 13.5,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: isSelected ? Colors.white : Colors.black87,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
