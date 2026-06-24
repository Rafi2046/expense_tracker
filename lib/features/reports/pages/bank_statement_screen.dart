import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/bank_statement_balance_card.dart';
import 'package:expense_tracker/features/reports/widgets/bank_statement_list.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';

class BankStatementScreen extends StatelessWidget {
  const BankStatementScreen({super.key});

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
    final isNotEmpty = reportsProvider.bankStatementTransactions.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bank Statement',
          style: AppTextStyles.reportAppBarTitle,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReportDateSelector(
                      dateRange: reportsProvider.selectedDateRange,
                      onRangeChanged: (range) {
                        reportsProvider.setDateRange(range);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isNotEmpty) ...[
                      const BankStatementBalanceCard(),
                      const SizedBox(height: 24),
                    ],
                    const BankStatementList(),
                  ],
                ),
              ),
            ),
            if (isNotEmpty)
              ReportBottomActions(
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
          ],
        ),
      ),
    );
  }
}
