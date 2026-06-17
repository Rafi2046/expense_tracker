import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_balance_header.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transaction_row.dart';
import 'package:expense_tracker/features/ledger/widgets/ledger_transactions_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock Transaction Data
    final transactions = [
      _MockTransaction(
        title: 'Apple Store',
        dateText: 'Oct 24, 2023',
        category: 'Electronics',
        amount: 999.00,
        isIncome: false,
        icon: Icons.shopping_bag_outlined,
      ),
      _MockTransaction(
        title: 'The Green Bistro',
        dateText: 'Oct 23, 2023',
        category: 'Dining',
        amount: 42.50,
        isIncome: false,
        icon: Icons.restaurant,
      ),
      _MockTransaction(
        title: 'Monthly Salary',
        dateText: 'Oct 20, 2023',
        category: 'Income',
        amount: 4500.00,
        isIncome: true,
        icon: Icons.payments_outlined,
      ),
      _MockTransaction(
        title: 'Uber Trip',
        dateText: 'Oct 19, 2023',
        category: 'Transport',
        amount: 15.20,
        isIncome: false,
        icon: Icons.directions_car_outlined,
      ),
      _MockTransaction(
        title: 'Streaming Service',
        dateText: 'Oct 18, 2023',
        category: 'Entertainment',
        amount: 12.99,
        isIncome: false,
        icon: Icons.play_circle_outline,
      ),
      _MockTransaction(
        title: 'Dividend Payout',
        dateText: 'Oct 15, 2023',
        category: 'Investment',
        amount: 125.40,
        isIncome: true,
        icon: Icons.savings_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSnackBar(context, 'Add transaction clicked'),
        backgroundColor: AppColors.activeGreen,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
                Text(
                  'Ledger',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 6),
                // Header Subtitle
                Text(
                  'Track your transaction history and balance.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.loginSubTitle,
                    fontFamily: GoogleFonts.workSans().fontFamily,
                  ),
                ),
                const SizedBox(height: 24),

                // Total Balance Header
                LedgerBalanceHeader(
                  balance: context.formatAmount(12450.00),
                  trendPercentage: '+2.4%',
                ),
                const SizedBox(height: 24),

                // Transactions Card
                LedgerTransactionsCard(
                  onFilterTap: () => _showSnackBar(context, 'Filter clicked'),
                  children: transactions
                      .map((tx) => LedgerTransactionRow(
                            title: tx.title,
                            dateText: tx.dateText,
                            category: tx.category,
                            amount: tx.amount,
                            isIncome: tx.isIncome,
                            icon: tx.icon,
                            onTap: () => _showSnackBar(
                              context,
                              'Tapped: ${tx.title}',
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MockTransaction {
  final String title;
  final String dateText;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;

  _MockTransaction({
    required this.title,
    required this.dateText,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });
}
