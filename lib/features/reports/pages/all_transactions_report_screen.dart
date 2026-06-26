import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_filter_bar.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_list.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_summary_grid.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/report_sort_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllTransactionsReportScreen extends StatelessWidget {
  const AllTransactionsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReportsProvider>();
    final currencySymbol = context.currencySymbol;
    final dateFormat = DateFormat('dd MMM yyyy');

    final headers = ['Date', 'Title', 'Category', 'Amount', 'Type', 'Payment Method'];
    final rows = provider.filteredTransactions.map((tx) => {
      'Date': dateFormat.format(tx.dateTime),
      'Title': tx.title,
      'Category': tx.subtitle,
      'Amount': '$currencySymbol ${tx.amount.toStringAsFixed(0)}',
      'Type': tx.type,
      'Payment Method': tx.paymentMethod,
    }).toList();
    final dateSubtitle = provider.getDateRangeSubtitle(provider.selectedOption, provider.selectedDateRange);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          'All Transactions Report',
          style: AppTextStyles.reportAppBarTitle.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
        ),
        centerTitle: true,
        actions: const [
          ReportSortButton(),
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.p16,
                right: AppSpacing.p16,
                top: AppSpacing.p20,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReportDateSelector(),
                  const SizedBox(height: 12),
                  const AllTransactionsFilterBar(),
                  const SizedBox(height: 16),
                  const AllTransactionsSummaryGrid(),
                  const SizedBox(height: 24),
                  Text(
                    'Transaction Lists',
                    style: AppTextStyles.reportSectionHeader.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 12),
                  const AllTransactionsList(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ReportBottomActions(
              reportName: 'All Transactions',
              title: 'All Transactions Report',
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
