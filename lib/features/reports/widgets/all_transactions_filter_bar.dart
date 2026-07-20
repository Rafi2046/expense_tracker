import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_select_sheet.dart';
import 'package:expense_tracker/features/reports/widgets/transaction_type_select_sheet.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AllTransactionsFilterBar extends StatefulWidget {
  const AllTransactionsFilterBar({super.key});

  @override
  State<AllTransactionsFilterBar> createState() => _AllTransactionsFilterBarState();
}

class _AllTransactionsFilterBarState extends State<AllTransactionsFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final reportsProvider = context.read<ReportsProvider>();
    _searchController = TextEditingController(text: reportsProvider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Search Input
        TextFormField(
          controller: _searchController,
          onChanged: (val) {
            reportsProvider.setAllTransactionsSearch(val);
          },
          style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: context.translate('search_transactions'),
            hintStyle: AppTextStyles.partyFormHint.copyWith(fontSize: AppFontSizes.size14, color: isDark ? Colors.white30 : null),
            prefixIcon: Icon(LucideIcons.search, color: isDark ? Colors.white30 : Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Chips Row
        Row(
          children: [
            // Type Selector Chip
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selected = await TransactionTypeSelectSheet.show(
                    context,
                    selectedType: reportsProvider.selectedType,
                  );
                  if (selected != null) {
                    reportsProvider.setAllTransactionsType(selected);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (() {
                          final type = reportsProvider.selectedType;
                          if (type == 'All Transactions') return context.translate('all_transactions');
                          if (type == 'Payment In') return context.translate('payment_in');
                          if (type == 'Payment Out') return context.translate('payment_out');
                          if (type == 'Expense') return context.translate('expense');
                          if (type == 'Income') return context.translate('income');
                          return type;
                        })(),
                        style: AppTextStyles.reportTileTitle.copyWith(fontSize: AppFontSizes.size11, color: theme.colorScheme.onSurface),
                      ),
                      Icon(
                        LucideIcons.chevronDown,
                        color: theme.colorScheme.onSurface,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Party Selector Chip
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selected = await PartySelectSheet.show(
                    context,
                    selectedPartyName: reportsProvider.selectedPartyName,
                  );
                  if (selected != null) {
                    reportsProvider.setAllTransactionsParty(
                      selected == 'clear_selection' ? null : selected,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reportsProvider.selectedPartyName ?? context.translate('select_party'),
                        style: AppTextStyles.reportTileTitle.copyWith(fontSize: AppFontSizes.size11, color: theme.colorScheme.onSurface),
                      ),
                      Icon(
                        LucideIcons.chevronDown,
                        color: theme.colorScheme.onSurface,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
