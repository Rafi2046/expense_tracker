import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';

class AllTransactionsList extends StatelessWidget {
  final bool isMasked;
  final bool isLoading;

  const AllTransactionsList({super.key, this.isMasked = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.filteredTransactions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('title'),
                        style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.translate('category')}  •  01 Jan 2024',
                        style: AppTextStyles.reportTransactionSubtitle.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳0,000',
                    style: AppTextStyles.reportTransactionTitle,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.transactionsIcon,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),
              Text(
                context.translate('no_transactions_matched_filters'),
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 4),
        ...List.generate(filtered.length * 2 - 1, (i) {
          if (i.isOdd) return const SizedBox(height: 10);
          final index = i ~/ 2;
        final tx = filtered[index];
        final isCredit = tx.type == 'Income' || tx.type == 'Payment In';
        final isTransaction = tx.type == 'Income' || tx.type == 'Expense';

        return Dismissible(
          key: ValueKey('${tx.id}_$index'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  isTransaction
                      ? context.translate('delete_transaction')
                      : context.translate('delete_debt'),
                ),
                content: Text(
                  '${context.translate('delete')} "${tx.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      context.translate('cancel'),
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      context.translate('delete'),
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.activeRed,
                      ),
                    ),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) {
            if (isTransaction) {
              context.read<TransactionProvider>().deleteTransaction(tx.id);
            } else {
              context.read<DebtProvider>().deleteDebtItem(tx.id);
            }
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.trash, color: Colors.white, size: 28),
          ),
          child: GestureDetector(
            onTap: () {
              if (isTransaction) {
                final tProvider = context.read<TransactionProvider>();
                final original = tProvider.transactions
                    .where((t) => t.id == tx.id)
                    .firstOrNull;
                if (original == null) return;
                AddTransactionSheet.show(
                  context: context,
                  isIncome: original.isIncome,
                  transaction: original,
                );
              } else {
                final dProvider = context.read<DebtProvider>();
                final original = dProvider.items
                    .where((d) => d.id == tx.id)
                    .firstOrNull;
                if (original == null) return;
                AddEditDebtSheet.show(
                  context: context,
                  item: original,
                  payeeLabel: tx.type == 'Payment In'
                      ? context.translate('client_friend_name')
                      : context.translate('payee_name'),
                  themeColor: isCredit ? theme.primaryColor : AppColors.activeRed,
                  isReceive: tx.type == 'Payment In',
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tx.subtitle} • ${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.reportTransactionSubtitle.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PrivacyMaskedText(
                    amount: tx.amount,
                    isMasked: isMasked,
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      color: isCredit ? theme.primaryColor : AppColors.activeRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      ],
    );
  }
}
