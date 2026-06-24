import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class CashStatementList extends StatelessWidget {
  const CashStatementList({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.cashStatementTransactions;
    final currencySymbol = context.currencySymbol;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.wallet_rounded, color: Colors.grey.shade300, size: 48),
              const SizedBox(height: 12),
              Text(
                'No cash transactions found',
                style: AppTextStyles.reportTransactionSubtitle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Lists',
          style: AppTextStyles.reportTransactionTitle,
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tx = filtered[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F1F1)),
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
                          style: AppTextStyles.reportTransactionTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tx.subtitle}\n${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                          style: AppTextStyles.reportTransactionSubtitle,
                        ),
                        const SizedBox(height: 8),
                        // Running Balance pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Bal: $currencySymbol ${tx.runningBalance.toStringAsFixed(0)}',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: AppColors.activeGreen,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$currencySymbol ${tx.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      color: tx.isCredit ? AppColors.activeGreen : AppColors.activeRed,
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
