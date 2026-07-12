import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/transaction_detail_cards.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isIncome = transaction.isIncome;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isIncome ? 'Income Details' : 'Expense Details',
          style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.edit,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.trash,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () => _confirmDelete(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TransactionInfoRow(transaction: transaction),
              const SizedBox(height: 12),
              CategoryDetailCard(category: transaction.category),
              const SizedBox(height: 12),
              AmountPaymentDetailCard(transaction: transaction),
              const SizedBox(height: 12),
              if (transaction.note.isNotEmpty) ...[
                MemoDetailCard(note: transaction.note),
                const SizedBox(height: 12),
              ],
              const SyncStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final onSurface = theme.colorScheme.onSurface;
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            'Delete Transaction',
            style: AppTextStyles.h3.copyWith(color: onSurface),
          ),
          content: Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.',
            style: AppTextStyles.body.copyWith(
              color: onSurface.withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.label.copyWith(
                  fontSize: AppFontSizes.size13,
                  color: onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                context.read<TransactionProvider>().deleteTransaction(
                  transaction.id,
                );
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction deleted successfully'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: AppTextStyles.label.copyWith(
                  fontSize: AppFontSizes.size13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    AddTransactionSheet.show(
      context: context,
      isIncome: transaction.isIncome,
      transaction: transaction,
    );
  }
}
