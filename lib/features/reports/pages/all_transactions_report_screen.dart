import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_filter_bar.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_list.dart';
import 'package:expense_tracker/features/reports/widgets/all_transactions_summary_grid.dart';
import 'package:expense_tracker/features/reports/widgets/privacy_toggle_section.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/report_sort_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class AllTransactionsReportScreen extends StatefulWidget {
  const AllTransactionsReportScreen({super.key});

  @override
  State<AllTransactionsReportScreen> createState() => _AllTransactionsReportScreenState();
}

class _AllTransactionsReportScreenState extends State<AllTransactionsReportScreen> {
  static bool _localMasked = false;
  bool _isScreenLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isScreenLoading = false);
    });
  }

  void _showAddOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.r24),
            topRight: Radius.circular(AppSpacing.r24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: AppSpacing.p8, bottom: AppSpacing.p8),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                ),
              ),
            ),
            ListTile(
              leading: Icon(LucideIcons.arrowDown, color: theme.primaryColor),
              title: Text(context.translate('income')),
              onTap: () {
                Navigator.pop(ctx);
                AddTransactionSheet.show(context: context, isIncome: true);
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.arrowUp, color: AppColors.activeRed),
              title: Text(context.translate('expense')),
              onTap: () {
                Navigator.pop(ctx);
                AddTransactionSheet.show(context: context, isIncome: false);
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.userCheck, color: theme.primaryColor),
              title: Text(context.translate('payment_in')),
              onTap: () {
                Navigator.pop(ctx);
                AddEditDebtSheet.show(
                  context: context,
                  payeeLabel: context.translate('client_friend_name'),
                  themeColor: theme.primaryColor,
                  isReceive: true,
                );
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.userX, color: AppColors.activeRed),
              title: Text(context.translate('payment_out')),
              onTap: () {
                Navigator.pop(ctx);
                AddEditDebtSheet.show(
                  context: context,
                  payeeLabel: context.translate('payee_name'),
                  themeColor: AppColors.activeRed,
                  isReceive: false,
                );
              },
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ReportsProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final currencySymbol = context.currencySymbol;
    final dateFormat = DateFormat('dd MMM yyyy');

    final headers = [
      context.translate('date'),
      context.translate('title'),
      context.translate('category'),
      context.translate('amount_label'),
      context.translate('type'),
      context.translate('payment_method'),
    ];
    final rows = provider.filteredTransactions.map((tx) => {
      'Date': dateFormat.format(tx.dateTime),
      'Title': tx.title,
      'Category': tx.subtitle,
      'Amount': '$currencySymbol ${tx.amount.toStringAsFixed(0)}',
      'Type': tx.type,
      'Payment Method': tx.paymentMethod,
    }).toList();
    final dateSubtitle = provider.getDateRangeSubtitle(provider.selectedOption, provider.selectedDateRange);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          context.translate('all_transactions_report'),
          style: AppTextStyles.reportAppBarTitle.copyWith(color: theme.appBarTheme.titleTextStyle?.color),
        ),
        centerTitle: true,
        actions: [
          const ReportSortButton(),
        ],
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
                top: AppSpacing.p16,
                bottom: 120,
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
                  const AllTransactionsFilterBar(),
                  const SizedBox(height: AppSpacing.s16),
                  AllTransactionsSummaryGrid(isMasked: _localMasked),
                  const SizedBox(height: AppSpacing.s24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('transaction_lists'),
                        style: AppTextStyles.reportSectionHeader.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      GestureDetector(
                        onTap: () => _showAddOptions(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.r24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.plus, size: 16, color: theme.primaryColor),
                              const SizedBox(width: AppSpacing.s8),
                              Text(
                                context.translate('Add New'),
                                style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
                                  color: theme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AllTransactionsList(
                    isMasked: _localMasked,
                    isLoading: txProvider.isLoading || _isScreenLoading,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ReportBottomActions(
              reportName: context.translate('all_transactions'),
              title: context.translate('all_transactions_report'),
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
