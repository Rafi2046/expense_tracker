import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_filter_bar.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_list.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_summary_grid.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/report_sort_button.dart';
import 'package:flutter/material.dart';

class AllTransactionsReportScreen extends StatelessWidget {
  const AllTransactionsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
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
      bottomNavigationBar: const ReportBottomActions(
        reportName: 'All Transactions',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 12.0,
            bottom: 100.0,
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
    );
  }
}
