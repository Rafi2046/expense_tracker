import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_selector.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_view_toggle.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_content.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_profile_header.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementScreen extends StatelessWidget {
  const PartyStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final theme = Theme.of(context);
    final currencySymbol = context.currencySymbol;
    final dateFormat = DateFormat('dd MMM yyyy');

    final headers = ['Date', 'Detail', 'Amount', 'Type'];
    final rows = reportsProvider.partyStatementTransactions.map((item) => {
      'Date': dateFormat.format(item.dateTime),
      'Detail': '${item.partyName} • ${item.description}',
      'Amount': '$currencySymbol ${item.amount.toStringAsFixed(0)}',
      'Type': item.isInflow ? 'Receive' : 'Give',
    }).toList();
    final dateSubtitle = reportsProvider.getDateRangeSubtitle(reportsProvider.selectedOption, reportsProvider.selectedDateRange);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
      body: Stack(
        children: [
          const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: 120.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportDateSelector(),
                  SizedBox(height: 12),
                  PartyStatementSelector(),
                  SizedBox(height: 16),
                  PartyStatementProfileHeader(),
                  SizedBox(height: 20),
                  PartyStatementContent(),
                ],
              ),
            ),
          ),
          if (partyName != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: ReportBottomActions(
                reportName: 'Party Statement',
                title: 'Party Statement - $partyName',
                dateSubtitle: dateSubtitle,
                headers: headers,
                rows: rows,
              ),
            ),
        ],
      ),
    );
  }
}
