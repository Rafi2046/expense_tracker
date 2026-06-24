import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PartyStatementTableView extends StatelessWidget {
  const PartyStatementTableView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;
    final totals = reportsProvider.partyStatementTotals;
    final currencySymbol = context.currencySymbol;

    if (partyName == null || transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final double netBalance = totals['netBalance'] ?? 0.0;
    final double receiveTotal = totals['receiveTotal'] ?? 0.0;
    final double giveTotal = totals['giveTotal'] ?? 0.0;

    // Calculate chronological running balances
    final chronological = transactions.reversed.toList();
    double balance = 0.0;
    final Map<String, double> runningBalances = {};
    for (var tx in chronological) {
      if (tx.isReceive) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
      runningBalances[tx.id] = balance;
    }

    final isReceivable = netBalance >= 0;
    final cardBgGradient = isReceivable
        ? const LinearGradient(
            colors: [Color(0xFFF4FBF9), Color(0xFFE8F7F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFF7F7), Color(0xFFFDECEC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final cardBorderColor = isReceivable ? const Color(0xFFD3EFE8) : const Color(0xFFFBD7D7);
    final cardAccentColor = isReceivable ? AppColors.activeGreen : AppColors.activeRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Net Balance Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: cardBgGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    color: cardAccentColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Net Balance',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: isReceivable ? const Color(0xFF146C48).withValues(alpha: 0.7) : const Color(0xFFDC3545).withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$currencySymbol ${netBalance.abs().toStringAsFixed(0)}',
                            style: AppTextStyles.reportLargeValue.copyWith(
                              color: cardAccentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transactions.length} entries',
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Debit ($currencySymbol)',
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: AppColors.activeGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currencySymbol ${receiveTotal.toStringAsFixed(0)}',
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: AppColors.activeGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Credit ($currencySymbol)',
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: AppColors.activeRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currencySymbol ${giveTotal.toStringAsFixed(0)}',
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: AppColors.activeRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFFF1F1F1), height: 1),
        const SizedBox(height: 12),

        // Table Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final txBal = runningBalances[tx.id] ?? 0.0;
            final isTxBalPositive = txBal >= 0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F1F1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.005),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Col 1: Details
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tx.detail,
                            style: AppTextStyles.reportTransactionTitle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy • h:mm a').format(tx.createdAt),
                                style: AppTextStyles.reportTransactionSubtitle.copyWith(fontSize: 10.5),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isTxBalPositive ? const Color(0xFFE8F8F5) : const Color(0xFFFDE8E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Bal: $currencySymbol${txBal.abs().toStringAsFixed(0)}',
                                  style: AppTextStyles.reportStatLabel.copyWith(
                                    color: isTxBalPositive ? AppColors.activeGreen : AppColors.activeRed,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Col 2: Debit (Receive)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      child: tx.isReceive
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F8F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1F2E5)),
                              ),
                              child: Text(
                                tx.amount.toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.reportTransactionTitle.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.activeGreen,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

                  // Col 3: Credit (Give)
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      child: !tx.isReceive
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFAD1D1)),
                              ),
                              child: Text(
                                tx.amount.toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.reportTransactionTitle.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.activeRed,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
