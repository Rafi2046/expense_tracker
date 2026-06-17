import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_month_selector.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_stats_cards.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final isSearching = provider.isSearching;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Ledger...',
                  hintStyle: GoogleFonts.workSans(color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
                onChanged: (val) => provider.updateSearchQuery(val),
              )
            : Text(
                'Ledger',
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: const Color(0xFF31394D),
            ),
            onPressed: () {
              final wasSearching = provider.isSearching;
              provider.toggleSearching(!wasSearching);
              if (wasSearching) {
                _searchController.clear();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F1F1), height: 1.0),
        ),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                  vertical: AppSpacing.p20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Summary Cards (Income vs Expense + Net Balance)
                    LedgerStatsCards(),
                    SizedBox(height: AppSpacing.s20),

                    // Month Selector Slider
                    LedgerMonthSelector(),
                    SizedBox(height: AppSpacing.s20),

                    // Transactions Card List
                    LedgerTransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F1F1), width: 1.0)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16,
          vertical: AppSpacing.p12,
        ),
        child: Row(
          children: [
            // Add Income Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                  ),
                  label: const Text('Add Income'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                    ),
                    textStyle: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    AddTransactionSheet.show(context: context, isIncome: true);
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Add Expense Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Add Expense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expensePink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.br12),
                    ),
                    textStyle: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    AddTransactionSheet.show(context: context, isIncome: false);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
