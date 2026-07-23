import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/cash_statement_balance_card.dart';
import 'package:expense_tracker/features/reports/widgets/cash_statement_list.dart';
import 'package:expense_tracker/features/reports/widgets/privacy_toggle_section.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CashInHandStatementScreen extends StatefulWidget {
  const CashInHandStatementScreen({super.key});

  @override
  State<CashInHandStatementScreen> createState() => _CashInHandStatementScreenState();
}

class _CashInHandStatementScreenState extends State<CashInHandStatementScreen> {
  static bool _localMasked = false;

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final isNotEmpty = reportsProvider.cashStatementTransactions.isNotEmpty;
    final theme = Theme.of(context);
    final currencySymbol = context.currencySymbol;
    final dateFormat = DateFormat('dd MMM yyyy');

    final headers = [
      context.translate('date'),
      context.translate('description_field'),
      context.translate('amount_label'),
      context.translate('type'),
      context.translate('balance'),
    ];
    final rows = reportsProvider.cashStatementTransactions.map((item) => {
      'Date': dateFormat.format(item.dateTime),
      'Description': item.subtitle,
      'Amount': '$currencySymbol ${item.amount.toStringAsFixed(0)}',
      'Type': item.isCredit ? context.translate('credit') : context.translate('debit'),
      'Balance': '$currencySymbol ${item.runningBalance.toStringAsFixed(0)}',
    }).toList();
    final dateSubtitle = reportsProvider.getDateRangeSubtitle(reportsProvider.selectedOption, reportsProvider.selectedDateRange);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          context.translate('cash_in_hand_statement'),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: AppSpacing.p16,
                right: AppSpacing.p16,
                top: AppSpacing.p12,
                bottom: 82.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrivacyToggleSection(
                    isMasked: _localMasked,
                    onToggle: () => setState(() => _localMasked = !_localMasked),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  const ReportDateSelector(),
                  const SizedBox(height: AppSpacing.s12),
                  if (isNotEmpty) ...[
                    CashStatementBalanceCard(isMasked: _localMasked),
                    const SizedBox(height: AppSpacing.s16),
                  ],
                  CashStatementList(isMasked: _localMasked),
                ],
              ),
            ),
          ),
          if (isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: ReportBottomActions(
                reportName: context.translate('cash_in_hand'),
                title: context.translate('cash_statement'),
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
