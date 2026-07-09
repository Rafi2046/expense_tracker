import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String accountType; // 'Cash' or 'Bank'

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

  // Calculate dynamic running balances and filter transactions for the specific account
  List<Map<String, dynamic>> _getProcessedTransactions(
    List<TransactionItem> allTransactions,
    List<DebtItem> debts,
  ) {
    List<dynamic> relevantItems = [];

    for (var tx in allTransactions) {
      if (tx.paymentMethod == widget.accountType) {
        relevantItems.add(tx);
      }
    }

    if (widget.accountType == 'Cash') {
      for (var d in debts) {
        relevantItems.add(d);
      }
    }

    relevantItems.sort((a, b) {
      DateTime aDate = a is TransactionItem ? a.dateTime : (a as DebtItem).createdAt;
      DateTime bDate = b is TransactionItem ? b.dateTime : (b as DebtItem).createdAt;
      return aDate.compareTo(bDate);
    });

    double currentRunningBalance = 0.0;
    List<Map<String, dynamic>> processedList = [];

    for (var item in relevantItems) {
      double amount = 0.0;
      bool isIncome = false;
      String title = '';
      String category = '';
      DateTime dateTime;
      String id = '';
      dynamic originalItem = item;

      if (item is TransactionItem) {
        amount = item.amount;
        isIncome = item.isIncome;
        title = item.note.isNotEmpty ? item.note : item.category;
        category = item.category;
        dateTime = item.dateTime;
        id = item.id;
      } else {
        final debt = item as DebtItem;
        amount = debt.amount;
        isIncome = debt.isReceive;
        title = debt.name.isNotEmpty ? debt.name : 'Debt adjustment';
        category = debt.isReceive ? 'To Receive' : 'To Give';
        dateTime = debt.createdAt;
        id = debt.id;
      }

      if (isIncome) {
        currentRunningBalance += amount;
      } else {
        currentRunningBalance -= amount;
      }

      processedList.add({
        'id': id,
        'amount': amount,
        'isIncome': isIncome,
        'title': title,
        'category': category,
        'dateTime': dateTime,
        'runningBalance': currentRunningBalance,
        'item': originalItem,
      });
    }

    processedList = processedList.reversed.toList();

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      processedList = processedList.where((item) {
        final title = item['title'].toString().toLowerCase();
        final cat = item['category'].toString().toLowerCase();
        return title.contains(query) || cat.contains(query);
      }).toList();
    }

    if (_selectedDateRange != null) {
      final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
      final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
      processedList = processedList.where((item) {
        final date = item['dateTime'] as DateTime;
        return !date.isBefore(start) && !date.isAfter(end);
      }).toList();
    }

    return processedList;
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final debtProvider = context.watch<DebtProvider>();

    double accountBalance = 0.0;
    for (var tx in txProvider.transactions) {
      if (tx.paymentMethod == widget.accountType) {
        if (tx.isIncome) {
          accountBalance += tx.amount;
        } else {
          accountBalance -= tx.amount;
        }
      }
    }
    if (widget.accountType == 'Cash') {
      for (var d in debtProvider.items) {
        if (d.isReceive) {
          accountBalance += d.amount;
        } else {
          accountBalance -= d.amount;
        }
      }
    }

    final processedTransactions = _getProcessedTransactions(
      txProvider.transactions,
      debtProvider.items,
    );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: theme.appBarTheme.iconTheme?.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.accountType == 'Cash' ? 'Cash' : 'Bank Account',
          style: AppTextStyles.reportAppBarTitle.copyWith(
            fontSize: AppFontSizes.size16,
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
                          style: GoogleFonts.workSans(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: AppFontSizes.size13,
                          ),
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
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
