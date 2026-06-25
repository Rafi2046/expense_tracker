import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LedgerTransactionList extends StatelessWidget {
  const LedgerTransactionList({super.key});

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

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.transactions,
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      );
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
    grouped.forEach((dateHeader, txs) {
      listItems.add(
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 4.0),
          child: Text(
            dateHeader.toUpperCase(),
            style: GoogleFonts.workSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
      
      for (var tx in txs) {
        listItems.add(
          Dismissible(
            key: ValueKey(tx.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: Text(
                    'Delete "${tx.note.isNotEmpty ? tx.note : tx.category}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel',
                        style: GoogleFonts.workSans(color: AppColors.textMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Delete',
                        style: GoogleFonts.workSans(color: AppColors.activeRed),
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
                  content: Text('Transaction deleted'),
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
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            ),
            child: LedgerTransactionRow(
              title: tx.note.isNotEmpty ? tx.note : tx.category,
              dateText: DateFormat('h:mm a').format(tx.dateTime),
              category: tx.category,
              amount: tx.amount,
              isIncome: tx.isIncome,
              icon: tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              incomeMonth: tx.incomeMonth,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listItems,
    );
  }
}
