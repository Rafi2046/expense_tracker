import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_select_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartyStatementSelector extends StatelessWidget {
  const PartyStatementSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final isSelected = partyName != null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            color: isSelected
                ? theme.primaryColor
                : (isDark ? theme.cardColor : const Color(0xFFF1F2F4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                partyName ?? context.translate('select_party'),
                style: AppTextStyles.reportTileTitle.copyWith(
                  fontSize: AppFontSizes.size14,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevronDown,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                size: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
