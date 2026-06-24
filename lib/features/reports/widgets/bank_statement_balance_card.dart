import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class BankStatementBalanceCard extends StatelessWidget {
  const BankStatementBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final closingBalance = reportsProvider.bankClosingBalance;
    final currencySymbol = context.currencySymbol;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Closing Balance',
            style: AppTextStyles.reportStatLabel,
          ),
          const SizedBox(height: 6),
          Text(
            '$currencySymbol ${closingBalance.toStringAsFixed(0)}',
            style: AppTextStyles.reportLargeValue.copyWith(
              color: closingBalance >= 0 ? AppColors.activeGreen : AppColors.activeRed,
            ),
          ),
        ],
      ),
    );
  }
}
