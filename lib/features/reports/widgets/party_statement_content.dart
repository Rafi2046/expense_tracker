import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_card_view.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_table_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementContent extends StatelessWidget {
  const PartyStatementContent({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;

    final theme = Theme.of(context);

    if (partyName == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.partyReportIcon, width: 150, height: 200),
              const SizedBox(height: 16),
              Text(
                'Select Party to View Report',
                style: AppTextStyles.reportAppBarTitle.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_rounded, color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200, size: 72),
              const SizedBox(height: 16),
              Text(
                'No Transactions Found',
                style: AppTextStyles.reportTransactionSubtitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (reportsProvider.partyStatementViewMode == PartyStatementViewMode.card) {
      return const PartyStatementCardView();
    } else {
      return const PartyStatementTableView();
    }
  }
}
