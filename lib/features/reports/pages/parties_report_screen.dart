import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_empty_state.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_filter_chips.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_header.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_summary_header.dart';
import 'package:expense_tracker/features/reports/widgets/party_list_tile.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartiesReportScreen extends StatefulWidget {
  const PartiesReportScreen({super.key});

  @override
  State<PartiesReportScreen> createState() => _PartiesReportScreenState();
}

class _PartiesReportScreenState extends State<PartiesReportScreen> {
  static bool _localMasked = false;
  PartiesFilter _selectedFilter = PartiesFilter.all;

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final allParties = reportsProvider.partyReportSummaries;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayList = switch (_selectedFilter) {
      PartiesFilter.all => allParties,
      PartiesFilter.debtors =>
          allParties.where((p) => p.netBalance < 0).toList(),
      PartiesFilter.creditors =>
          allParties.where((p) => p.netBalance >= 0).toList(),
    };

    final totalToReceive = allParties
        .where((p) => p.netBalance > 0)
        .fold<double>(0, (sum, p) => sum + p.netBalance);
    final totalToGive = allParties
        .where((p) => p.netBalance < 0)
        .fold<double>(0, (sum, p) => sum + p.netBalance.abs());

    final headers = ['Name', 'Phone', 'Net Balance', 'Transactions'];
    final rows = allParties
        .map(
          (item) => {
            'Name': item.name,
            'Phone': item.phone ?? '-',
            'Net Balance':
                '${context.currencySymbol} ${item.netBalance.toStringAsFixed(0)}',
            'Transactions': item.transactionCount.toString(),
          },
        )
        .toList();
    final dateSubtitle = reportsProvider.getDateRangeSubtitle(
      reportsProvider.selectedOption,
      reportsProvider.selectedDateRange,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          'Parties Report',
          style: AppTextStyles.reportAppBarTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 12.0,
                bottom: 120.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PartiesReportHeader(
                    isMasked: _localMasked,
                    onToggle: () =>
                        setState(() => _localMasked = !_localMasked),
                    searchQuery: reportsProvider.partiesSearchQuery,
                    onSearchChanged: (val) {
                      reportsProvider.setPartiesSearch(val);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  PartiesReportFilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) =>
                        setState(() => _selectedFilter = filter),
                  ),
                  const SizedBox(height: 16),
                  PartiesReportSummaryHeader(
                    totalToReceive: totalToReceive,
                    totalToGive: totalToGive,
                    isMasked: _localMasked,
                  ),
                  const SizedBox(height: 20),
                  displayList.isEmpty
                      ? PartiesReportEmptyState(isDark: isDark)
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            return PartyListTile(
                              item: item,
                              isMasked: _localMasked,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PartyStatementScreen(
                                    initialPartyName: item.name,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ReportBottomActions(
              reportName: 'Parties Report',
              title: 'Parties Report',
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
