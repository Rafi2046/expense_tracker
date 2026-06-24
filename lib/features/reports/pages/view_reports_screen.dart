import 'package:expense_tracker/features/reports/models/report_item.dart';
import 'package:expense_tracker/features/reports/pages/all_transactions_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/bank_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/cash_in_hand_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/income_expense_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/parties_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
import 'package:expense_tracker/features/reports/widgets/report_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Reports',
          style: GoogleFonts.workSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF0F0F0), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B6B45), Color(0xFF2EBD85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Reports',
                          style: GoogleFonts.workSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track, analyze & export your data',
                          style: GoogleFonts.workSans(
                            fontSize: 11.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            _buildSectionLabel('POPULAR REPORTS'),
            const SizedBox(height: 10),

            _buildReportCard(context, items: [
              const ReportItem(
                icon: Icons.receipt_long_rounded,
                title: 'All Transactions',
                subtitle: 'Complete transaction history',
                destination: AllTransactionsReportScreen(),
              ),
              const ReportItem(
                icon: Icons.people_alt_outlined,
                title: 'Party Statement',
                subtitle: 'View per-party ledger',
                destination: PartyStatementScreen(),
              ),
              const ReportItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Cash In Hand',
                subtitle: 'Track your cash balance',
                destination: CashInHandStatementScreen(),
              ),
              const ReportItem(
                icon: Icons.account_balance_outlined,
                title: 'Bank Statement',
                subtitle: 'Bank account summary',
                destination: BankStatementScreen(),
              ),
            ]),

            const SizedBox(height: 22),
            _buildSectionLabel('BROWSE ALL'),
            const SizedBox(height: 10),

            _buildReportCard(context, items: [
              const ReportItem(
                icon: Icons.people_outline_rounded,
                title: 'Parties Report',
                subtitle: 'Payable & receivable overview',
                destination: PartiesReportScreen(),
              ),
              const ReportItem(
                icon: Icons.trending_up_rounded,
                title: 'Income & Expense',
                subtitle: 'Profit/loss breakdown',
                destination: IncomeExpenseReportScreen(),
              ),
            ]),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {required List<ReportItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ReportTile(item: item),
              if (!isLast)
                Divider(
                  color: Colors.grey.shade100,
                  height: 1,
                  indent: 60,
                  endIndent: 16,
                ),
            ],
          );
        }),
      ),
    );
  }
}
