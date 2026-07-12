import 'package:expense_tracker/features/transactions/widgets/transaction_header.dart';
import 'package:expense_tracker/features/transactions/widgets/transaction_filters.dart';
import 'package:expense_tracker/features/transactions/widgets/transaction_summary_card.dart';
import 'package:expense_tracker/features/transactions/widgets/transactions_month_selector.dart';
import 'package:expense_tracker/features/transactions/widgets/ledger_transaction_list.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
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

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).padding.bottom),
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
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          heroTag: 'ledger_fab',
          onPressed: () => _showAddOptions(context),
          child: Icon(LucideIcons.plus),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
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
                // Stats Summary Cards (Income vs Expense + Net Balance)
                TransactionSummaryCard(
                  isMasked: _localMasked,
                  onToggleMask: () => setState(() => _localMasked = !_localMasked),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Month Selector Slider
                const TransactionsMonthSelector(),
                const SizedBox(height: 12),

                // Filter: All / Income / Expense
                TransactionFilters(
                  selectedFilter: provider.transactionTypeFilter,
                  isDark: isDark,
                  onFilterChanged: (filter) => provider.transactionTypeFilter = filter,
                ),

                LedgerTransactionList(isMasked: _localMasked, isLoading: isLoading),
              ],
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
              Icon(LucideIcons.chevronRight, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
