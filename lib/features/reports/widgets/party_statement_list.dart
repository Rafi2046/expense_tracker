import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class PartyStatementList extends StatelessWidget {
  const PartyStatementList({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;
    final currencySymbol = context.currencySymbol;

    if (partyName == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.partyReportIcon, width: 150, height: 200),

              Text(
                'Select Party to View Report',
                style: AppTextStyles.reportAppBar,
              ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No transactions in this period',
            style: AppTextStyles.reportTransactionSubtitle.copyWith(
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaction Lists', style: AppTextStyles.reportTransactionTitle),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tx = transactions[index];

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.detail,
                        style: AppTextStyles.reportTransactionTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(tx.createdAt),
                        style: AppTextStyles.reportTransactionSubtitle,
                      ),
                    ],
                  ),
                  Text(
                    '$currencySymbol ${tx.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      color: tx.isReceive
                          ? AppColors.activeGreen
                          : AppColors.activeRed,
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
