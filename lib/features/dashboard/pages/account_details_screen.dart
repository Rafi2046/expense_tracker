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
import 'package:expense_tracker/features/dashboard/pages/to_receive_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/to_give_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AccountTab { all, toReceive, toGive }

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
  AccountTab _selectedTab = AccountTab.all;

  static const int _initialLimit = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterByTab(List<Map<String, dynamic>> items) {
    if (_selectedTab == AccountTab.all) return items;
    return items.where((item) {
      final raw = item['item'];
      if (raw is DebtItem) {
        return _selectedTab == AccountTab.toReceive ? raw.isReceive : !raw.isReceive;
      }
      return false;
    }).toList();
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

    final tabbedItems = _filterByTab(processedTransactions);
    final displayItems = tabbedItems.take(_initialLimit).toList();
    final hasMore = tabbedItems.length > _initialLimit;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          widget.accountType,
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

              // Tab Bar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF0F1F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildTab('All', AccountTab.all),
                    const SizedBox(width: 4),
                    _buildTab('To Receive', AccountTab.toReceive),
                    const SizedBox(width: 4),
                    _buildTab('To Give', AccountTab.toGive),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // View All row
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_selectedTab == AccountTab.toReceive) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ToReceiveScreen()));
                          } else if (_selectedTab == AccountTab.toGive) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ToGiveScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => _AllItemsViewScreen(items: tabbedItems, accountType: widget.accountType)));
                          }
                        },
                        child: Text(
                          'View All',
                          style: AppTextStyles.bodyBold.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF2EBD85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Transaction List
              Expanded(
                child: displayItems.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: AppTextStyles.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          return AccountTransactionRow(item: item, accountType: widget.accountType);
                        },
                      ),
              ),

              // Bottom Button: Adjust Balance
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

  Color _tabColor(AccountTab tab) {
    switch (tab) {
      case AccountTab.all:
        return const Color(0xFF7C3AED);
      case AccountTab.toReceive:
        return const Color(0xFF2EBD85);
      case AccountTab.toGive:
        return const Color(0xFFDC3545);
    }
  }

  Widget _buildTab(String label, AccountTab tab) {
    final isSelected = _selectedTab == tab;
    final color = _tabColor(tab);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = tab);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AllItemsViewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String accountType;

  const _AllItemsViewScreen({required this.items, required this.accountType});

  @override
  Widget build(BuildContext context) {
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
          'All Transactions',
          style: AppTextStyles.h3.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => AccountTransactionRow(
              item: items[index],
              accountType: accountType,
            ),
          ),
        ),
      ),
    );
  }
}
