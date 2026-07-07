import 'package:material_symbols_icons/symbols.dart';
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
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
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

  Widget _buildSegment(BuildContext context, TransactionProvider provider, String label, TransactionTypeFilter filter, bool isDark) {
    final isSelected = provider.transactionTypeFilter == filter;
    Color selectedColor;
    switch (filter) {
      case TransactionTypeFilter.income:
        selectedColor = AppColors.activeGreen;
      case TransactionTypeFilter.expense:
        selectedColor = AppColors.expensePink;
      case TransactionTypeFilter.all:
        selectedColor = isDark ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade500;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.transactionTypeFilter = filter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
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
              icon: Symbols.account_balance_wallet,
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
              icon: Symbols.payments,
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  color: onSurface,
                ),
                decoration: InputDecoration(
                  hintText: context.translate('search_hint'),
                  hintStyle: GoogleFonts.workSans(color: isDark ? Colors.white38 : Colors.grey.shade400),
                  border: InputBorder.none,
                ),
                onChanged: (val) => provider.updateSearchQuery(val),
              )
            : Text(
                context.translate('ledger'),
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Symbols.close_rounded : Symbols.search_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF31394D),
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
          child: Container(
            color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          heroTag: 'ledger_fab',
          onPressed: () => _showAddOptions(context),
          child: const Icon(Symbols.add_rounded),
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
                LedgerStatsCards(
                  isMasked: _localMasked,
                  onToggleMask: () => setState(() => _localMasked = !_localMasked),
                ),
                const SizedBox(height: AppSpacing.s20),

                // Month Selector Slider
                const LedgerMonthSelector(),
                const SizedBox(height: 12),

                // Filter: All / Income / Expense
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F1F3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildSegment(context, provider, 'All', TransactionTypeFilter.all, isDark),
                      const SizedBox(width: 4),
                      _buildSegment(context, provider, 'Income', TransactionTypeFilter.income, isDark),
                      const SizedBox(width: 4),
                      _buildSegment(context, provider, 'Expense', TransactionTypeFilter.expense, isDark),
                    ],
                  ),
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
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Symbols.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
