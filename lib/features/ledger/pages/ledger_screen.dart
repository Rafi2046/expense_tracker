import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_month_selector.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_stats_cards.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
                  hintText: context.translate('search_hint'),
                  hintStyle: GoogleFonts.workSans(color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
                onChanged: (val) => provider.updateSearchQuery(val),
              )
            : Text(
                context.translate('ledger'),
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Summary Cards (Income vs Expense + Net Balance)
              const LedgerStatsCards(),
              const SizedBox(height: AppSpacing.s20),

              // Month Selector Slider
              const LedgerMonthSelector(),
              const SizedBox(height: 12),

              // Inline Add Income & Add Expense Buttons Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: Color(0xFF006C49),
                        ),
                        label: Text(
                          context.translate('add_income'),
                          style: GoogleFonts.workSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF006C49),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F3EE),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          AddTransactionSheet.show(
                            context: context,
                            isIncome: true,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: Color(0xFFD9383A),
                        ),
                        label: Text(
                          context.translate('add_expense'),
                          style: GoogleFonts.workSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD9383A),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFFDECEC),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          AddTransactionSheet.show(
                            context: context,
                            isIncome: false,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              LedgerTransactionList(),
            ],
          ),
        ),
      ),
    );
  }
}
