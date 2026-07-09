import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/bank_statement_list.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BankStatementDetailsScreen extends StatelessWidget {
  final bool isMasked;

  const BankStatementDetailsScreen({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.bankStatementTransactions;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Transactions',
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
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) => BankStatementList.buildTxCard(context, filtered[index], isMasked),
      ),
    );
  }
}