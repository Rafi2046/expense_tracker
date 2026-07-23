import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_empty_state.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_filter_chips.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_header.dart';
import 'package:expense_tracker/features/reports/widgets/parties_report_summary_header.dart';
import 'package:expense_tracker/features/reports/widgets/party_list_tile.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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

    final headers = [
      context.translate('name'),
      context.translate('phone'),
      context.translate('net_balance'),
      context.translate('transactions'),
    ];
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
          context.translate('parties_report'),
          style: AppTextStyles.reportAppBarTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color),
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
                left: AppSpacing.p16,
                right: AppSpacing.p16,
                top: AppSpacing.p12,
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
                  const SizedBox(height: AppSpacing.s16),
                  PartiesReportFilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) =>
                        setState(() => _selectedFilter = filter),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  PartiesReportSummaryHeader(
                    totalToReceive: totalToReceive,
                    totalToGive: totalToGive,
                    isMasked: _localMasked,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  displayList.isEmpty
                      ? PartiesReportEmptyState(isDark: isDark)
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.s8),
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            return Dismissible(
                              key: ValueKey('party_${item.name}'),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
                                    title: Text(context.translate('delete_party'), style: TextStyle(color: theme.colorScheme.onSurface)),
                                    content: Text(
                                      context.translate('delete_entries_for', namedArgs: {'name': item.name}),
                                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, false),
                                        child: Text(context.translate('cancel'), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, true),
                                        child: Text(context.translate('delete'), style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                                return confirmed == true;
                              },
                              onDismissed: (direction) {
                                final debtProvider = context.read<DebtProvider>();
                                final partyDebts = debtProvider.items.where((d) => d.name == item.name).toList();
                                for (final d in partyDebts) {
                                  debtProvider.deleteDebtItem(d.id);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(context.translate('name_deleted', namedArgs: {'name': item.name})), duration: const Duration(seconds: 2)),
                                );
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(context.translate('delete'), style: AppTextStyles.bodyBold.copyWith(color: Colors.red.shade400)),
                                    const SizedBox(width: AppSpacing.s8),
                                    Icon(LucideIcons.trash2, color: Colors.red.shade400, size: 22),
                                  ],
                                ),
                              ),
                              child: PartyListTile(
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
              reportName: context.translate('parties_report'),
              title: context.translate('parties_report'),
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
