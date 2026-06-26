import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/bank_statement_balance_card.dart';
import 'package:expense_tracker/features/reports/widgets/bank_statement_list.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankStatementScreen extends StatelessWidget {
  const BankStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final isNotEmpty = reportsProvider.bankStatementTransactions.isNotEmpty;
    final theme = Theme.of(context);
    final currencySymbol = context.currencySymbol;
    final dateFormat = DateFormat('dd MMM yyyy');

    final headers = ['Date', 'Description', 'Amount', 'Type', 'Balance'];
    final rows = reportsProvider.bankStatementTransactions.map((item) => {
      'Date': dateFormat.format(item.dateTime),
      'Description': item.subtitle,
      'Amount': '$currencySymbol ${item.amount.toStringAsFixed(0)}',
      'Type': item.isCredit ? 'Credit' : 'Debit',
      'Balance': '$currencySymbol ${item.runningBalance.toStringAsFixed(0)}',
    }).toList();
    final dateSubtitle = reportsProvider.getDateRangeSubtitle(reportsProvider.selectedOption, reportsProvider.selectedDateRange);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          'Bank Statement',
          style: AppTextStyles.reportAppBarTitle.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      bottomNavigationBar: isNotEmpty
          ? ReportBottomActions(
              reportName: 'Bank Statement',
              title: 'Bank Statement',
              dateSubtitle: dateSubtitle,
              headers: headers,
              rows: rows,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReportDateSelector(),
              const SizedBox(height: 12),
              if (isNotEmpty) ...[
                const BankStatementBalanceCard(),
                const SizedBox(height: 16),
              ],
              const BankStatementList(),
            ],
          ),
        ),
      ),
    );
  }
}
