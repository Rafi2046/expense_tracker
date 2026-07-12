import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_card_view.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_dummy_card_view.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_dummy_table_view.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_empty_state.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_no_transactions.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_table_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/model/party_statement_entry.dart';

class PartyStatementContent extends StatelessWidget {
  final bool isMasked;
  final bool isLoading;

  const PartyStatementContent({super.key, this.isMasked = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;

    if (partyName == null) {
      return const PartyStatementEmptyState();
    }

    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: _buildDummyContent(context, reportsProvider.partyStatementViewMode),
      );
    }

    if (transactions.isEmpty) {
      return const PartyStatementNoTransactions();
    }

    if (reportsProvider.partyStatementViewMode == PartyStatementViewMode.card) {
      return PartyStatementCardView(isMasked: isMasked);
    } else {
      return PartyStatementTableView(isMasked: isMasked);
    }
  }

  Widget _buildDummyContent(BuildContext context, PartyStatementViewMode viewMode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dummyEntries = List.generate(5, (i) {
      return PartyStatementEntry(
        id: 'skel_$i',
        partyName: 'Party Name',
        description: 'Transaction description skeleton $i',
        amount: [500.0, 1200.0, 300.0, 2500.0, 800.0][i],
        isInflow: i.isEven,
        dateTime: DateTime.now().subtract(Duration(days: i)),
      );
    });

    if (viewMode == PartyStatementViewMode.card) {
      return PartyStatementDummyCardView(
          entries: dummyEntries, theme: theme, isDark: isDark);
    } else {
      return PartyStatementDummyTableView(
          entries: dummyEntries, theme: theme, isDark: isDark);
    }
  }
}
