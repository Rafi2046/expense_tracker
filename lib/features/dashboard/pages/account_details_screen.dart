import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_transaction_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_balance_header_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_date_selector.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_search_bar.dart';
import 'package:expense_tracker/features/dashboard/widgets/adjust_balance_actions.dart';
import 'package:expense_tracker/features/dashboard/utils/transaction_processor.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class AccountDetailsScreen extends StatefulWidget {
  final String accountType;

  const AccountDetailsScreen({super.key, required this.accountType});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  DateRangeOption _selectedOption = DateRangeOption.allTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final debtProvider = context.watch<DebtProvider>();

    final accountBalance = TransactionProcessor.calculateAccountBalance(
      allTransactions: txProvider.transactions,
      debts: debtProvider.items,
      accountType: widget.accountType,
    );

    final processedTransactions = TransactionProcessor.getProcessedTransactions(
      allTransactions: txProvider.transactions,
      debts: debtProvider.items,
      accountType: widget.accountType,
      searchQuery: _searchQuery,
      selectedDateRange: _selectedDateRange,
    );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.accountType == 'Cash' ? 'Cash' : 'Bank Account',
          style: AppTextStyles.h3.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerTheme.color,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              AccountBalanceHeaderCard(
                accountType: widget.accountType,
                balance: accountBalance,
              ),
              const SizedBox(height: 12),
              AccountDateSelector(
                selectedOption: _selectedOption,
                selectedDateRange: _selectedDateRange,
                onDateSelected: (option, range) {
                  setState(() {
                    _selectedOption = option;
                    _selectedDateRange = range;
                  });
                },
              ),
              const SizedBox(height: 10),
              AccountSearchBar(
                controller: _searchController,
                searchQuery: _searchQuery,
                hasActiveFilters: _selectedDateRange != null || _searchQuery.isNotEmpty,
                onSearchChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onResetFilters: () {
                  setState(() {
                    _selectedDateRange = null;
                    _selectedOption = DateRangeOption.allTime;
                    _searchQuery = '';
                  });
                },
              ),
              const SizedBox(height: 12),

              // Transaction List (Compact)
              Expanded(
                child: processedTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: AppTextStyles.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: processedTransactions.length,
                        itemBuilder: (context, index) {
                          final item = processedTransactions[index];
                          return AccountTransactionRow(item: item);
                        },
                      ),
              ),

              // Bottom Button: Adjust Balance (Compact)
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => showAdjustBalanceBottomSheet(context, initialAccount: widget.accountType),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Adjust Balance',
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
