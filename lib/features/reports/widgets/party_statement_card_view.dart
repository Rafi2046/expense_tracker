import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_money_flow_card.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_net_balance_card.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class PartyStatementCardView extends StatelessWidget {
  final bool isMasked;

  const PartyStatementCardView({super.key, this.isMasked = false});

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

    double moneyIn = 0.0;
    double moneyOut = 0.0;
    for (var entry in transactions) {
      if (entry.isOpeningBalance) continue;
      if (entry.isInflow) {
        moneyIn += entry.amount;
      } else {
        moneyOut += entry.amount;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReceivable = netBalance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PartyStatementNetBalanceCard(
          netBalance: netBalance,
          isReceivable: isReceivable,
          isMasked: isMasked,
          isDark: isDark,
        ),
        const SizedBox(height: AppSpacing.s12),

        Row(
          children: [
            Expanded(
              child: PartyStatementMoneyFlowCard(
                isInflow: true,
                amount: moneyIn,
                isMasked: isMasked,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: PartyStatementMoneyFlowCard(
                isInflow: false,
                amount: moneyOut,
                isMasked: isMasked,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s24),

        Text(
          'Transactions',
          style: AppTextStyles.reportTransactionTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s8),
          itemBuilder: (context, index) {
            final entry = transactions[index];
            return PartyStatementTransactionTile(
              entryId: entry.id,
              description: entry.description,
              dateTime: entry.dateTime,
              amount: entry.amount,
              isInflow: entry.isInflow,
              isOpeningBalance: entry.isOpeningBalance,
              isMasked: isMasked,
            );
          },
        ),
      ],
    );
  }
}
