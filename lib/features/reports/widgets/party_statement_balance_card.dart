import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class PartyStatementBalanceCard extends StatelessWidget {
  const PartyStatementBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final totals = reportsProvider.partyStatementTotals;
    final currencySymbol = context.currencySymbol;

    if (partyName == null) return const SizedBox.shrink();

    final double netBalance = totals['netBalance'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            partyName,
            style: AppTextStyles.reportTransactionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    netBalance >= 0 ? 'To Receive' : 'To Give',
                    style: AppTextStyles.reportStatLabel,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currencySymbol ${netBalance.abs().toStringAsFixed(0)}',
                    style: AppTextStyles.reportLargeValue.copyWith(
                      color: netBalance >= 0 ? AppColors.activeGreen : AppColors.activeRed,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (netBalance >= 0 ? AppColors.activeGreen : AppColors.activeRed).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  netBalance >= 0 ? 'RECEIVABLE' : 'PAYABLE',
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: netBalance >= 0 ? AppColors.activeGreen : AppColors.activeRed,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
