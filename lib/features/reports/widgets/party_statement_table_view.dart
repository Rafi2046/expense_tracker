import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_net_balance_card.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_table_header.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_table_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class PartyStatementTableView extends StatelessWidget {
  final bool isMasked;

  const PartyStatementTableView({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;
    final totals = reportsProvider.partyStatementTotals;

    if (partyName == null || transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final double netBalance = totals['netBalance'] ?? 0.0;
    final double receiveTotal = totals['receiveTotal'] ?? 0.0;
    final double giveTotal = totals['giveTotal'] ?? 0.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isReceivable = netBalance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PartyStatementNetBalanceCard(
          netBalance: netBalance,
          isReceivable: isReceivable,
          isMasked: isMasked,
          isDark: isDark,
          label: context.translate('net_balance'),
        ),
        const SizedBox(height: AppSpacing.s24),

        PartyStatementTableHeader(
          entryCount: transactions.length,
          receiveTotal: receiveTotal,
          giveTotal: giveTotal,
          isMasked: isMasked,
        ),
        const SizedBox(height: AppSpacing.s8),
        Divider(color: theme.dividerColor, height: 1),
        const SizedBox(height: AppSpacing.s12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s8),
          itemBuilder: (context, index) {
            final entry = transactions[index];

            return PartyStatementTableRow(
              description: entry.description,
              dateTime: entry.dateTime,
              amount: entry.amount,
              isInflow: entry.isInflow,
              isMasked: isMasked,
              isDark: isDark,
              onTap: () {
                if (entry.id.startsWith('tx_')) {
                  final originalId = entry.id.substring(3);
                  final txP = context.read<TransactionProvider>();
                  final tx = txP.transactions
                      .where((t) => t.id == originalId)
                      .firstOrNull;
                  if (tx == null) return;
                  AddTransactionSheet.show(
                    context: context,
                    isIncome: entry.isInflow,
                    transaction: tx,
                  );
                } else if (entry.id.startsWith('debt_')) {
                  final originalId = entry.id.substring(5);
                  final debtP = context.read<DebtProvider>();
                  final debt = debtP.items
                      .where((d) => d.id == originalId)
                      .firstOrNull;
                  if (debt == null) return;
                  AddEditDebtSheet.show(
                    context: context,
                    item: debt,
                    payeeLabel: entry.isInflow ? context.translate('client_friend_name') : context.translate('payee_name'),
                    themeColor: entry.isInflow ? theme.primaryColor : AppColors.activeRed,
                    isReceive: entry.isInflow,
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}
