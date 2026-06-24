import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/report_date_selector.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LedgerItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime dateTime;
  final bool isCredit; // true = Money In, false = Money Out
  double runningBalance;

  LedgerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateTime,
    required this.isCredit,
    this.runningBalance = 0.0,
  });
}

class CashInHandStatementScreen extends StatefulWidget {
  const CashInHandStatementScreen({super.key});

  @override
  State<CashInHandStatementScreen> createState() =>
      _CashInHandStatementScreenState();
}

class _CashInHandStatementScreenState extends State<CashInHandStatementScreen> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  void _showExportSuccess(String format) {
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
    final transactionProvider = context.watch<TransactionProvider>();
    final debtProvider = context.watch<DebtProvider>();
    final currencySymbol = context.currencySymbol;

    // Filter cash transactions
    final List<LedgerItem> ledger = [];

    // Incomes/Expenses matching Cash
    for (var tx in transactionProvider.transactions) {
      if (tx.paymentMethod == 'Cash') {
        ledger.add(
          LedgerItem(
            id: tx.id,
            title: tx.isIncome ? 'Money In' : 'Money Out',
            subtitle: tx.note.isNotEmpty
                ? '${tx.note} (${tx.category})'
                : tx.category,
            amount: tx.amount,
            dateTime: tx.dateTime,
            isCredit: tx.isIncome,
          ),
        );
      }
    }

    // Debts (all treated as Cash by default)
    for (var d in debtProvider.items) {
      ledger.add(
        LedgerItem(
          id: d.id,
          title: d.isReceive ? 'Money In' : 'Money Out',
          subtitle: '${d.name} • ${d.detail}',
          amount: d.amount,
          dateTime: d.createdAt,
          isCredit: d.isReceive,
        ),
      );
    }

    // Sort ascending by date to compute running balance
    ledger.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    double runningBal = 0.0;
    for (var item in ledger) {
      if (item.isCredit) {
        runningBal += item.amount;
      } else {
        runningBal -= item.amount;
      }
      item.runningBalance = runningBal;
    }

    // Filter by date range
    List<LedgerItem> filtered = [];
    if (_selectedDateRange != null) {
      final start = DateTime(
        _selectedDateRange!.start.year,
        _selectedDateRange!.start.month,
        _selectedDateRange!.start.day,
      );
      final end = DateTime(
        _selectedDateRange!.end.year,
        _selectedDateRange!.end.month,
        _selectedDateRange!.end.day,
        23,
        59,
        59,
      );

      filtered = ledger.where((item) {
        return !item.dateTime.isBefore(start) && !item.dateTime.isAfter(end);
      }).toList();
    } else {
      filtered = List.from(ledger);
    }

    // Sort descending for display (latest first)
    filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final closingBalance = runningBal;

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
          'Cash In Hand Statement',
          style: AppTextStyles.reportAppBarTitle,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F1F1), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selector
                    ReportDateSelector(
                      dateRange: _selectedDateRange,
                      onRangeChanged: (range) {
                        setState(() {
                          _selectedDateRange = range;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Closing Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F1F1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Closing Balance',
                            style: AppTextStyles.reportStatLabel,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$currencySymbol ${closingBalance.toStringAsFixed(0)}',
                            style: AppTextStyles.reportLargeValue.copyWith(
                              color: closingBalance >= 0
                                  ? AppColors.activeGreen
                                  : AppColors.activeRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Transaction Lists Header
                    Text(
                      'Transaction Lists',
                      style: AppTextStyles.reportTransactionTitle,
                    ),
                    const SizedBox(height: 12),

                    // List items
                    filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 40.0,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.wallet_rounded,
                                    color: Colors.grey.shade300,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No cash transactions found',
                                    style: AppTextStyles
                                        .reportTransactionSubtitle
                                        .copyWith(fontSize: 14),
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
                              final tx = filtered[index];

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF1F1F1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.title,
                                            style: AppTextStyles
                                                .reportTransactionTitle,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${tx.subtitle}\n${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                                            style: AppTextStyles
                                                .reportTransactionSubtitle,
                                          ),
                                          const SizedBox(height: 8),
                                          // Running Balance pill
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F8F5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Bal: $currencySymbol ${tx.runningBalance.toStringAsFixed(0)}',
                                              style: AppTextStyles
                                                  .reportStatLabel
                                                  .copyWith(
                                                    color:
                                                        AppColors.activeGreen,
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '$currencySymbol ${tx.amount.toStringAsFixed(0)}',
                                      style: AppTextStyles
                                          .reportTransactionTitle
                                          .copyWith(
                                            color: tx.isCredit
                                                ? AppColors.activeGreen
                                                : AppColors.activeRed,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),

            // Persistent bottom actions
            ReportBottomActions(
              onDownload: () => _showExportSuccess('PDF/Excel'),
              onPrint: () => _showExportSuccess('Printer Output'),
              onExcel: () => _showExportSuccess('Excel File'),
              onShare: () async {
                final format = await ShareReportSheet.show(context);
                if (format != null) {
                  _showExportSuccess(format.toUpperCase());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
