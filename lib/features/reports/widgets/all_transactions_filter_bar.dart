import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_select_sheet.dart';
import 'package:expense_tracker/features/reports/widgets/transaction_type_select_sheet.dart';

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

    return Column(
      children: [
        // Search Input
        TextFormField(
          controller: _searchController,
          onChanged: (val) {
            reportsProvider.setAllTransactionsSearch(val);
          },
          style: AppTextStyles.partyFormInput,
          decoration: InputDecoration(
            hintText: 'Search Transactions...',
            hintStyle: AppTextStyles.partyFormHint.copyWith(fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.activeGreen, width: 1.5),
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
                    color: const Color(0xFFF1F2F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reportsProvider.selectedType,
                        style: AppTextStyles.reportTileTitle.copyWith(fontSize: 11.5),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black87),
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
                    color: const Color(0xFFF1F2F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reportsProvider.selectedPartyName ?? 'Select Party',
                        style: AppTextStyles.reportTileTitle.copyWith(fontSize: 11.5),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black87),
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
