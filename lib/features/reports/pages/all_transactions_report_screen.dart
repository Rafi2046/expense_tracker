import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_filter_bar.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_list.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_summary_grid.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:expense_tracker/features/reports/widgets/sort_by_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';

class AllTransactionsReportScreen extends StatelessWidget {
  const AllTransactionsReportScreen({super.key});

  void _showExportSuccess(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Report exported to $format successfully!',
              style: AppTextStyles.partySubmitButtonText.copyWith(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: AppColors.activeGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Transactions Report',
          style: AppTextStyles.reportAppBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black87),
            onPressed: () async {
              final selected = await SortBySheet.show(
                context,
                currentOption: reportsProvider.sortOption,
              );
              if (selected != null) {
                reportsProvider.setSortOption(selected);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      bottomNavigationBar: ReportBottomActions(
        onDownload: () => _showExportSuccess(context, 'PDF/Excel'),
        onPrint: () => _showExportSuccess(context, 'Printer Output'),
        onExcel: () => _showExportSuccess(context, 'Excel File'),
        onShare: () async {
          final format = await ShareReportSheet.show(context);
          if (format != null && context.mounted) {
            _showExportSuccess(context, format.toUpperCase());
          }
        },
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
                style: AppTextStyles.reportSectionHeader.copyWith(color: Colors.black87),
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
