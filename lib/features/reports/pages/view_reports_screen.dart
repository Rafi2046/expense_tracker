import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/pages/all_transactions_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/bank_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/cash_in_hand_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/income_expense_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/parties_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
import 'package:flutter/material.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'View Reports',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Popular Reports'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F1F1)),
              ),
              child: Column(
                children: [
                  _buildReportTile(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'All Transactions Report',
                    destination: const AllTransactionsReportScreen(),
                  ),
                  _buildDivider(),
                  _buildReportTile(
                    context,
                    icon: Icons.people_alt_outlined,
                    title: 'Party Statement',
                    destination: const PartyStatementScreen(),
                  ),
                  _buildDivider(),
                  _buildReportTile(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Cash In Hand Statement',
                    destination: const CashInHandStatementScreen(),
                  ),
                  _buildDivider(),
                  _buildReportTile(
                    context,
                    icon: Icons.account_balance_outlined,
                    title: 'Bank Statement',
                    destination: const BankStatementScreen(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Browse All Reports'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F1F1)),
              ),
              child: Column(
                children: [
                  _buildReportTile(
                    context,
                    icon: Icons.people_outline_rounded,
                    title: 'Parties Report',
                    destination: const PartiesReportScreen(),
                  ),
                  _buildDivider(),
                  _buildReportTile(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Income Expense Report',
                    destination: const IncomeExpenseReportScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: AppTextStyles.reportSectionHeader,
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Icon(icon, color: AppColors.activeGreen, size: 24),
      title: Text(
        title,
        style: AppTextStyles.reportTileTitle,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFF8FAFC),
      height: 1,
      indent: 56,
    );
  }
}
