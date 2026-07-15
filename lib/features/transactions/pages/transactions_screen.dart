import 'package:expense_tracker/features/transactions/widgets/transaction_header.dart';
import 'package:expense_tracker/features/transactions/widgets/transaction_summary_card.dart';
import 'package:expense_tracker/features/transactions/widgets/transactions_month_selector.dart';
import 'package:expense_tracker/features/transactions/widgets/ledger_transaction_list.dart';
import 'package:expense_tracker/features/transactions/widgets/transaction_period_selector.dart';
import 'package:expense_tracker/features/transactions/widgets/transaction_date_selector.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  static bool _localMasked = false;
  bool _isScreenLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isScreenLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterBottomSheet(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final activeSort = provider.sortOption;
            final activeType = provider.transactionTypeFilter;
            final isDarkSheet = Theme.of(context).brightness == Brightness.dark;
            final accentColor = const Color(0xFF6A53A1);

            Widget buildSortItem(
              String title,
              TransactionSortOption option,
              IconData icon,
            ) {
              final isSelected = activeSort == option;
              return InkWell(
                onTap: () {
                  provider.updateSortOption(option);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected ? accentColor : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? accentColor
                                : (isDarkSheet
                                      ? Colors.white70
                                      : Colors.black87),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: accentColor, size: 18),
                    ],
                  ),
                ),
              );
            }

            Widget buildTypeItem(
              String title,
              TransactionTypeFilter filter,
              IconData icon,
              Color color,
            ) {
              final isSelected = activeType == filter;
              return InkWell(
                onTap: () {
                  provider.transactionTypeFilter = filter;
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected ? color : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? color
                                : (isDarkSheet
                                      ? Colors.white70
                                      : Colors.black87),
                          ),
                        ),
                      ),
                      if (isSelected) Icon(Icons.check, color: color, size: 18),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDarkSheet
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sort & Filter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: isDarkSheet ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SORT BY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildSortItem(
                      'Latest',
                      TransactionSortOption.latest,
                      Icons.calendar_today,
                    ),
                    buildSortItem(
                      'Amount: High to Low',
                      TransactionSortOption.amountHighToLow,
                      Icons.trending_down,
                    ),
                    buildSortItem(
                      'Amount: Low to High',
                      TransactionSortOption.amountLowToHigh,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'FILTER BY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildTypeItem(
                      'All Transactions',
                      TransactionTypeFilter.all,
                      Icons.list,
                      accentColor,
                    ),
                    buildTypeItem(
                      'Income Only',
                      TransactionTypeFilter.income,
                      Icons.arrow_downward,
                      const Color(0xFF2ECC71),
                    ),
                    buildTypeItem(
                      'Expense Only',
                      TransactionTypeFilter.expense,
                      Icons.arrow_upward,
                      const Color(0xFFF1948A),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(ctx).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _AddOptionTile(
              icon: LucideIcons.wallet,
              label: 'Add Income',
              subtitle: 'Record money received',
              color: AppColors.activeGreen,
              bgColor: AppColors.activeGreen.withValues(alpha: 0.08),
              onTap: () {
                Navigator.pop(ctx);
                AddTransactionSheet.show(context: context, isIncome: true);
              },
            ),
            const SizedBox(height: 12),
            _AddOptionTile(
              icon: LucideIcons.creditCard,
              label: 'Add Expense',
              subtitle: 'Record money spent',
              color: AppColors.expensePink,
              bgColor: AppColors.expensePink.withValues(alpha: 0.08),
              onTap: () {
                Navigator.pop(ctx);
                AddTransactionSheet.show(context: context, isIncome: false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final isSearching = provider.isSearching;
    final isLoading = provider.isLoading || _isScreenLoading;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: TransactionHeader(
        isSearching: isSearching,
        isDark: isDark,
        onSurface: onSurface,
        searchController: _searchController,
        onSearchToggle: () {
          final wasSearching = provider.isSearching;
          provider.toggleSearching(!wasSearching);
          if (wasSearching) {
            _searchController.clear();
          }
        },
        onSearchChanged: (val) => provider.updateSearchQuery(val),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: FloatingActionButton(
          heroTag: 'ledger_fab',
          backgroundColor: const Color(0xFF2ECC71),
          foregroundColor: Colors.white,
          onPressed: () => _showAddOptions(context),
          child: const Icon(LucideIcons.plus),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: const Color(0xFF6A53A1),
          onRefresh: () async {
            await context.read<ProfileProvider>().reload();
            provider.updateProfileId(provider.activeProfileId);
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: AppSpacing.p16,
              right: AppSpacing.p16,
              top: AppSpacing.p20,
              bottom: 120,
            ),
            child: Skeletonizer(
              enabled: isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stats Summary Cards (Income vs Expense + Net Balance)
                  TransactionSummaryCard(
                    isMasked: _localMasked,
                    onToggleMask: () =>
                        setState(() => _localMasked = !_localMasked),
                  ),
                  const SizedBox(height: 16),

                  // 2. Period Selector (Daily / Monthly / Yearly)
                  TransactionPeriodSelector(
                    selectedPeriod: provider.selectedPeriod,
                    isDark: isDark,
                    onPeriodChanged: (period) =>
                        provider.setSelectedPeriod(period),
                  ),
                  const SizedBox(height: 12),

                  // 3. Date / Month Selector based on selected period
                  if (provider.selectedPeriod == TransactionPeriod.monthly)
                    TransactionsMonthSelector(
                      onFilterTap: () => _showSortFilterBottomSheet(context),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TransactionDateSelector(
                            provider: provider,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 44,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? (Theme.of(context).dividerTheme.color ??
                                        const Color(0xFF2D2D2D))
                                  : const Color(0xFFF1F1F1),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(LucideIcons.slidersHorizontal, size: 18),
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF31394D),
                            onPressed: () =>
                                _showSortFilterBottomSheet(context),
                          ),
                        ),
                      ],
                    ),

                  // 4. Transactions List
                  LedgerTransactionList(
                    isMasked: _localMasked,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.reportTileTitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
