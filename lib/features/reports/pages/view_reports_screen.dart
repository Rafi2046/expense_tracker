import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/reports/models/report_item.dart';
import 'package:expense_tracker/features/reports/pages/all_transactions_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/bank_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/cash_in_hand_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/income_expense_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/parties_report_screen.dart';
import 'package:expense_tracker/features/reports/pages/party_statement_screen.dart';
import 'package:expense_tracker/features/reports/widgets/report_tile.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ViewReportsScreen extends StatelessWidget {
  const ViewReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: theme.appBarTheme.iconTheme?.color),
        title: Text(
          context.translate('reports'),
          style: AppTextStyles.h2.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerTheme.color ?? const Color(0xFFF0F0F0), height: 1.0),
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
                          context.translate('financial_reports'),
                          style: AppTextStyles.reportTransactionTitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.translate('financial_reports_subtitle'),
                          style: AppTextStyles.caption.copyWith(
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
                    child: Icon(LucideIcons.barChart, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            _buildSectionLabel(context, context.translate('popular_reports')),
            const SizedBox(height: 10),

            _buildReportCard(context, items: [
              const ReportItem(
                icon: LucideIcons.receipt,
                title: 'All Transactions',
                subtitle: 'Complete transaction history',
                destination: AllTransactionsReportScreen(),
              ),
              const ReportItem(
                icon: LucideIcons.users,
                title: 'Party Statement',
                subtitle: 'View per-party ledger',
                destination: PartyStatementScreen(),
              ),
              const ReportItem(
                icon: LucideIcons.wallet,
                title: 'Cash In Hand',
                subtitle: 'Track your cash balance',
                destination: CashInHandStatementScreen(),
              ),
              const ReportItem(
                icon: LucideIcons.landmark,
                title: 'Bank Statement',
                subtitle: 'Bank account summary',
                destination: BankStatementScreen(),
              ),
            ]),

            const SizedBox(height: 22),
            _buildSectionLabel(context, context.translate('browse_all')),
            const SizedBox(height: 10),

            _buildReportCard(context, items: [
              const ReportItem(
                icon: LucideIcons.users,
                title: 'Parties Report',
                subtitle: 'Payable & receivable overview',
                destination: PartiesReportScreen(),
              ),
              const ReportItem(
                icon: LucideIcons.trendingUp,
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

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontSize: AppFontSizes.size10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {required List<ReportItem> items}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                  color: theme.dividerTheme.color ?? Colors.grey.shade100,
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
