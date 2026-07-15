import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/transaction_models.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/pages/transaction_details_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/income_transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IncomeTransactionListScreen extends StatelessWidget {
  final String title;
  final List<TransactionItem> transactions;
  final bool isMasked;

  const IncomeTransactionListScreen({
    super.key,
    required this.title,
    required this.transactions,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTextStyles.insightsHeaderTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerTheme.color, height: 1.0),
        ),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Text(
                context.translate('no_transactions_found'),
                style: AppTextStyles.reportTileTitle.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final categoryLower = tx.category.toLowerCase();
                IconData icon;
                if (categoryLower.contains('salary')) {
                  icon = LucideIcons.landmark;
                } else if (categoryLower.contains('freelance') || categoryLower.contains('business') || categoryLower.contains('work')) {
                  icon = LucideIcons.briefcase;
                } else if (categoryLower.contains('dividend') || categoryLower.contains('invest') || categoryLower.contains('saving')) {
                  icon = LucideIcons.lineChart;
                } else {
                  icon = LucideIcons.building2;
                }
                return IncomeTransactionRow(
                  icon: icon,
                  title: tx.note.isNotEmpty ? tx.note : tx.category,
                  subtitle: '${DateFormat('MMM dd, yyyy').format(tx.dateTime)} • ${tx.category}',
                  amount: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('+ ', style: AppTextStyles.reportTileTitle.copyWith(color: const Color(0xFF2EBD85))),
                      PrivacyMaskedText(
                        amount: tx.amount,
                        isMasked: isMasked,
                        style: AppTextStyles.reportTileTitle.copyWith(color: const Color(0xFF2EBD85)),
                      ),
                    ],
                  ),
                  status: 'completed',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailsScreen(transaction: tx),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
