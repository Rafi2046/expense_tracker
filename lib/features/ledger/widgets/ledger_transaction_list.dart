import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LedgerTransactionList extends StatelessWidget {
  const LedgerTransactionList({super.key});

  String _getGroupHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
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
      final header = _getGroupHeader(tx.dateTime);
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
          LedgerTransactionRow(
            title: tx.note.isNotEmpty ? tx.note : tx.category,
            dateText: DateFormat('h:mm a').format(tx.dateTime), // simplified time format
            category: tx.category,
            amount: tx.amount,
            isIncome: tx.isIncome,
            icon: tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Transaction details: ${tx.note.isNotEmpty ? tx.note : tx.category}',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
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
