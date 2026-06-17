import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LedgerTransactionList extends StatelessWidget {
  const LedgerTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final filteredTransactions = provider.filteredTransactions;

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No transactions found for this period.',
            style: GoogleFonts.workSans(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final tx = filteredTransactions[index];
        return LedgerTransactionRow(
          title: tx.note.isNotEmpty ? tx.note : tx.category,
          dateText: DateFormat('dd MMM yyyy • h:mm a').format(tx.dateTime),
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
        );
      },
    );
  }
}
