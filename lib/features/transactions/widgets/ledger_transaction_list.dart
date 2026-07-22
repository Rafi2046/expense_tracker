import 'package:expense_tracker/features/transactions/widgets/transaction_list_tile.dart';
import 'package:expense_tracker/features/transactions/widgets/transaction_empty_state.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LedgerTransactionList extends StatelessWidget {
  final bool isMasked;
  final bool isLoading;

  const LedgerTransactionList({super.key, this.isMasked = false, this.isLoading = false});

  String _getGroupHeader(BuildContext context, DateTime dateTime, String locale) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (txDate == today) {
      return context.translate('today');
    } else if (txDate == yesterday) {
      return context.translate('yesterday');
    } else {
      return DateFormat('dd MMMM yyyy', locale).format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final locale = context.watch<LanguageProvider>().currentLanguageCode;
    final filteredTransactions = provider.filteredTransactions;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Column(
        children: List.generate(6, (i) => TransactionListTile(
          key: ValueKey('ledger_skeleton_$i'),
          title: context.translate('loading_transaction'),
          dateText: '12:00 PM',
          category: 'Category',
          amount: 0.0,
          isIncome: i.isEven,
          icon: i.isEven ? LucideIcons.arrowDown : LucideIcons.arrowUp,
          isMasked: isMasked,
          onTap: () {},
        )),
      );
    }

    if (filteredTransactions.isEmpty) {
      return const TransactionEmptyState();
    }

    // Group transactions by date
    final Map<String, List<TransactionItem>> grouped = {};
    for (var tx in filteredTransactions) {
      final header = _getGroupHeader(context, tx.dateTime, locale);
      if (grouped[header] == null) {
        grouped[header] = [];
      }
      grouped[header]!.add(tx);
    }

    final List<Widget> listItems = [];
    final seenKeys = <String>{};
    grouped.forEach((dateHeader, txs) {
      listItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            dateHeader.toUpperCase(),
            style: AppTextStyles.reportStatLabel.copyWith(
              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
      
      for (var tx in txs) {
        if (!seenKeys.add(tx.id)) continue;
        listItems.add(
          Dismissible(
            key: ValueKey(tx.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(context.translate('delete_transaction')),
                  content: Text(
                    'Delete "${tx.note.isNotEmpty ? tx.note : tx.category}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                    child: Text(context.translate('cancel'),
                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(context.translate('delete'),
                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.activeRed),
                    ),
                  ),
                  ],
                ),
              ) ?? false;
            },
            onDismissed: (_) {
              context.read<TransactionProvider>().deleteTransaction(tx.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translate('transaction_deleted_success')),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.activeRed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(LucideIcons.trash, color: Colors.white, size: 28),
            ),
            child: TransactionListTile(
              title: tx.note.isNotEmpty ? tx.note : tx.category,
              dateText: DateFormat('h:mm a').format(tx.dateTime),
              category: tx.category,
              amount: tx.amount,
              isIncome: tx.isIncome,
              icon: tx.isIncome ? LucideIcons.arrowDown : LucideIcons.arrowUp,
              incomeMonth: tx.incomeMonth,
              isMasked: isMasked,
              onTap: () {
                AddTransactionSheet.show(
                  context: context,
                  isIncome: tx.isIncome,
                  transaction: tx,
                );
              },
            ),
          ),
        );
      }
    });

    listItems.add(const SizedBox(height: 100));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listItems,
    );
  }
}
