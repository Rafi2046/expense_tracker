import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/reports/pages/all_transactions_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/bank_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/cash_in_hand_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/income_expense_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/parties_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
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
              _ReportItem(
                icon: Icons.receipt_long_rounded,
                title: 'All Transactions',
                subtitle: 'Complete transaction history',
                destination: const AllTransactionsReportScreen(),
              ),
              _ReportItem(
                icon: Icons.people_alt_outlined,
                title: 'Party Statement',
                subtitle: 'View per-party ledger',
                destination: const PartyStatementScreen(),
              ),
              _ReportItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Cash In Hand',
                subtitle: 'Track your cash balance',
                destination: const CashInHandStatementScreen(),
              ),
              _ReportItem(
                icon: Icons.account_balance_outlined,
                title: 'Bank Statement',
                subtitle: 'Bank account summary',
                destination: const BankStatementScreen(),
              ),
            ]),

            const SizedBox(height: 22),
            _buildSectionLabel('BROWSE ALL'),
            const SizedBox(height: 10),

            _buildReportCard(context, items: [
              _ReportItem(
                icon: Icons.people_outline_rounded,
                title: 'Parties Report',
                subtitle: 'Payable & receivable overview',
                destination: const PartiesReportScreen(),
              ),
              _ReportItem(
                icon: Icons.trending_up_rounded,
                title: 'Income & Expense',
                subtitle: 'Profit/loss breakdown',
                destination: const IncomeExpenseReportScreen(),
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

  Widget _buildReportCard(BuildContext context, {required List<_ReportItem> items}) {
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
              _buildReportTile(context, item: item),
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

  Widget _buildReportTile(BuildContext context, {required _ReportItem item}) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.destination),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.activeGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppColors.activeGreen, size: 18),
            ),
            const SizedBox(width: 14),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.workSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _ReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}
