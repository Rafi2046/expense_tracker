import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_selector.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_view_toggle.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_content.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_profile_header.dart';
import 'package:expense_tracker/features/reports/widgets/privacy_toggle_section.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyStatementScreen extends StatefulWidget {
  final String? initialPartyName;

  const PartyStatementScreen({super.key, this.initialPartyName});

  @override
  State<PartyStatementScreen> createState() => _PartyStatementScreenState();
}

class _PartyStatementScreenState extends State<PartyStatementScreen> {
  static bool _localMasked = false;
  bool _isScreenLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialPartyName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final provider = context.read<ReportsProvider>();
          provider.setDateRangeOption(DateRangeOption.allTime);
          provider.setStatementParty(widget.initialPartyName);
        }
      });
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isScreenLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    final headers = ['Date', 'Detail', 'Amount', 'Type'];
    final rows = reportsProvider.partyStatementTransactions
        .map(
          (item) => {
            'Date': dateFormat.format(item.dateTime),
            'Detail': '${item.partyName} • ${item.description}',
            'Amount':
                '${context.currencySymbol} ${item.amount.toStringAsFixed(0)}',
            'Type': item.isInflow ? 'Receive' : 'Give',
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
        leadingWidth: 86,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: BackButton(color: theme.appBarTheme.iconTheme?.color),
          ),
        ),
        title: Text(
          'Party Statement',
          style: AppTextStyles.reportAppBarTitle.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        actions: const [PartyStatementViewToggle(), SizedBox(width: 8)],
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
                  const ReportDateSelector(),
                  const SizedBox(height: 12),
                  const PartyStatementSelector(),
                  const SizedBox(height: 16),
                  const PartyStatementProfileHeader(),
                  const SizedBox(height: 20),
                  PartyStatementContent(
                    isMasked: _localMasked,
                    isLoading:
                        txProvider.isLoading ||
                        (_isScreenLoading && partyName != null),
                  ),
                ],
              ),
            ),
          ),
          if (partyName != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: ReportBottomActions(
                reportName: 'Party Statement',
                title: 'Party Statement - $partyName',
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
