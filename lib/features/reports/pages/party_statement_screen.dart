import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_selector.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_view_toggle.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_content.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';

class PartyStatementScreen extends StatelessWidget {
  const PartyStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 86,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: BackButton(color: theme.appBarTheme.iconTheme?.color),
          ),
        ),
        title: Text(
          'Party Statement',
          style: AppTextStyles.reportAppBarTitle.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
        ),
        centerTitle: true,
        actions: const [
          PartyStatementViewToggle(),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      bottomNavigationBar: partyName != null
          ? const ReportBottomActions(
              reportName: 'Party Statement',
            )
          : null,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 100.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportDateSelector(),
              SizedBox(height: 12),
              PartyStatementSelector(),
              SizedBox(height: 24),
              PartyStatementContent(),
            ],
          ),
        ),
      ),
    );
  }
}
