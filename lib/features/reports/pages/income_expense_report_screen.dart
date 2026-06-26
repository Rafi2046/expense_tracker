import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/model/category_summary.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/income_expense_summary_card.dart';
import 'package:expense_tracker/features/reports/widgets/income_expense_category_lists.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IncomeExpenseReportScreen extends StatelessWidget {
  const IncomeExpenseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReportsProvider>();
    final currencySymbol = context.currencySymbol;
    final data = provider.incomeExpenseData;

    final expenseSummaries = (data['expenseSummaries'] as List<CategorySummary>);
    final incomeSummaries = (data['incomeSummaries'] as List<CategorySummary>);
    final headers = ['Category', 'Amount', 'Type', 'Count'];
    final rows = [
      ...expenseSummaries.map((s) => {
        'Category': s.categoryName,
        'Amount': '$currencySymbol ${s.totalAmount.toStringAsFixed(0)}',
        'Type': 'Expense',
        'Count': s.transactionCount.toString(),
      }),
      ...incomeSummaries.map((s) => {
        'Category': s.categoryName,
        'Amount': '$currencySymbol ${s.totalAmount.toStringAsFixed(0)}',
        'Type': 'Income',
        'Count': s.transactionCount.toString(),
      }),
    ];
    final dateSubtitle = provider.getDateRangeSubtitle(provider.selectedOption, provider.selectedDateRange);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          'Income Expense Report',
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
      bottomNavigationBar: ReportBottomActions(
        reportName: 'Income Expense',
        title: 'Income Expense Report',
        dateSubtitle: dateSubtitle,
        headers: headers,
        rows: rows,
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
              const SizedBox(height: 16),
              const IncomeExpenseSummaryCard(),
              const SizedBox(height: 24),
              const IncomeExpenseCategoryLists(),
            ],
          ),
        ),
      ),
    );
  }
}
