import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/widgets/party_select_sheet.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_balance_card.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_list.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';

class PartyStatementScreen extends StatelessWidget {
  const PartyStatementScreen({super.key});

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
    final partyName = reportsProvider.selectedPartyNameForStatement;

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
          'Party Statement',
          style: AppTextStyles.reportAppBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Colors.black87),
            onPressed: () {},
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
      bottomNavigationBar: partyName != null
          ? ReportBottomActions(
              onDownload: () => _showExportSuccess(context, 'PDF/Excel'),
              onPrint: () => _showExportSuccess(context, 'Printer Output'),
              onExcel: () => _showExportSuccess(context, 'Excel File'),
              onShare: () async {
                final format = await ShareReportSheet.show(context);
                if (format != null && context.mounted) {
                  _showExportSuccess(context, format.toUpperCase());
                }
              },
            )
          : null,
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

              // Party Selector Dropdown Chip
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () async {
                    final selected = await PartySelectSheet.show(
                      context,
                      selectedPartyName: partyName,
                    );
                    if (selected != null) {
                      reportsProvider.setStatementParty(
                        selected == 'clear_selection' ? null : selected,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          partyName ?? 'Select Party',
                          style: AppTextStyles.reportTileTitle.copyWith(fontSize: 13.5),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const PartyStatementBalanceCard(),
              if (partyName != null) const SizedBox(height: 24),
              const PartyStatementList(),
            ],
          ),
        ),
      ),
    );
  }
}
