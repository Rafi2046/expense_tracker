import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/reports/widgets/privacy_toggle_section.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.partyReportSummaries;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headers = ['Name', 'Phone', 'Net Balance', 'Transactions'];
    final rows = filtered
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
                  PrivacyToggleSection(
                    isMasked: _localMasked,
                    onToggle: () =>
                        setState(() => _localMasked = !_localMasked),
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  TextFormField(
                    initialValue: reportsProvider.partiesSearchQuery,
                    onChanged: (val) {
                      reportsProvider.setPartiesSearch(val);
                    },
                    style: AppTextStyles.partyFormInput.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search parties...',
                      hintStyle: AppTextStyles.partyFormHint.copyWith(
                        fontSize: 14,
                        color: isDark ? Colors.white30 : null,
                      ),
                      prefixIcon: Icon(
                        Symbols.search,
                        color: isDark ? Colors.white30 : Colors.grey.shade400,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme.dividerTheme.color ?? Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              theme.dividerTheme.color ?? Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Parties list
                  filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60.0),
                            child: Column(
                              children: [
                                Icon(
                                  Symbols.people_outline_rounded,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No parties found',
                                  style: AppTextStyles.reportTransactionSubtitle
                                      .copyWith(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isReceivable = item.netBalance >= 0;

                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PartyStatementScreen(
                                    initialPartyName: item.name,
                                  ),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        theme.dividerTheme.color ??
                                        const Color(0xFFF1F1F1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white10
                                                : const Color(0xFFF1F2F4),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              item.initials,
                                              style: AppTextStyles
                                                  .reportTileTitle
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: AppTextStyles
                                                  .reportTransactionTitle
                                                  .copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.phone ?? "No phone"} • ${item.transactionCount} txs',
                                              style: AppTextStyles
                                                  .reportTransactionSubtitle
                                                  .copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isReceivable
                                              ? 'To Receive'
                                              : 'To Give',
                                          style: AppTextStyles.reportStatLabel
                                              .copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.5),
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        PrivacyMaskedText(
                                          amount: item.netBalance.abs(),
                                          isMasked: _localMasked,
                                          style: AppTextStyles
                                              .reportTransactionTitle
                                              .copyWith(
                                                color: item.netBalance == 0
                                                    ? (isDark
                                                          ? Colors.white38
                                                          : Colors
                                                                .grey
                                                                .shade600)
                                                    : (isReceivable
                                                          ? theme.primaryColor
                                                          : AppColors
                                                                .activeRed),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
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
