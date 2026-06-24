import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:expense_tracker/features/reports/widgets/share_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartyReportSummary {
  final String name;
  final String? phone;
  final double netBalance; // positive = Receivable (To Receive), negative = Payable (To Give)
  final int transactionCount;

  PartyReportSummary({
    required this.name,
    this.phone,
    required this.netBalance,
    required this.transactionCount,
  });
}

class PartiesReportScreen extends StatefulWidget {
  const PartiesReportScreen({super.key});

  @override
  State<PartiesReportScreen> createState() => _PartiesReportScreenState();
}

class _PartiesReportScreenState extends State<PartiesReportScreen> {
  String _searchQuery = '';

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
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
    final debtProvider = context.watch<DebtProvider>();
    final currencySymbol = context.currencySymbol;

    // Group debt items by party name
    final Map<String, List<DebtItem>> grouped = {};
    for (var item in debtProvider.items) {
      grouped.putIfAbsent(item.name, () => []).add(item);
    }

    final List<PartyReportSummary> summaries = [];
    grouped.forEach((name, items) {
      double net = 0.0;
      String? phone;

      for (var item in items) {
        if (item.phone != null) phone = item.phone;
        if (item.isReceive) {
          net += item.amount;
        } else {
          net -= item.amount;
        }
      }

      summaries.add(PartyReportSummary(
        name: name,
        phone: phone,
        netBalance: net,
        transactionCount: items.length,
      ));
    });

    // Filter by search query
    final filtered = summaries.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      final matchName = item.name.toLowerCase().contains(q);
      final matchPhone = item.phone?.toLowerCase().contains(q) ?? false;
      return matchName || matchPhone;
    }).toList();

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
          'Parties Report',
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
                    // Search bar
                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: AppTextStyles.partyFormInput,
                      decoration: InputDecoration(
                        hintText: 'Search parties...',
                        hintStyle: AppTextStyles.partyFormHint.copyWith(fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.activeGreen, width: 1.5),
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
                                  Icon(Icons.people_outline_rounded, color: Colors.grey.shade300, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No parties found',
                                    style: AppTextStyles.reportTransactionSubtitle.copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isReceivable = item.netBalance >= 0;

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFF1F1F1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF1F2F4),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getInitials(item.name),
                                              style: AppTextStyles.reportTileTitle.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: AppTextStyles.reportTransactionTitle,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.phone ?? "No phone"} • ${item.transactionCount} txs',
                                              style: AppTextStyles.reportTransactionSubtitle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isReceivable ? 'To Receive' : 'To Give',
                                          style: AppTextStyles.reportStatLabel,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$currencySymbol ${item.netBalance.abs().toStringAsFixed(0)}',
                                          style: AppTextStyles.reportTransactionTitle.copyWith(
                                            color: item.netBalance == 0
                                                ? Colors.grey.shade600
                                                : (isReceivable ? AppColors.activeGreen : AppColors.activeRed),
                                          ),
                                        ),
                                      ],
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
