import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/report_bottom_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartiesReportScreen extends StatelessWidget {
  const PartiesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final currencySymbol = context.currencySymbol;
    final filtered = reportsProvider.partyReportSummaries;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black87),
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
                      initialValue: reportsProvider.partiesSearchQuery,
                      onChanged: (val) {
                        reportsProvider.setPartiesSearch(val);
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
                                              item.initials,
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
            const ReportBottomActions(
              reportName: 'Parties Report',
            ),
          ],
        ),
      ),
    );
  }
}
