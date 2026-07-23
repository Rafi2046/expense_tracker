import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/recent_activity_date_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/recent_activity_item_card.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class RecentActivityScreen extends StatelessWidget {
  const RecentActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final groups = _groupByDate(context.watch<TransactionProvider>().transactions);

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: t.appBarTheme.backgroundColor,
        elevation: 0, scrolledUnderElevation: 0,
        leading: BackButton(color: t.appBarTheme.iconTheme?.color),
        title: Text(context.translate('recent_activity'), style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700, color: t.colorScheme.onSurface)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: t.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),
        ),
      ),
      body: groups.isEmpty
          ? Center(child: Text(context.translate('no_transactions'), style: AppTextStyles.body.copyWith(color: Colors.grey.shade400)))
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                20 + MediaQuery.of(context).padding.bottom + 80,
              ),
              itemCount: groups.length,
              itemBuilder: (_, i) => _buildGroup(context, groups[i]),
            ),
    );
  }

  Widget _buildGroup(BuildContext context, _DateGroup g) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecentActivityDateHeader(label: g.dateLabel),
        const SizedBox(height: AppSpacing.s8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: t.cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 3))],
            border: Border.all(color: t.dividerTheme.color ?? const Color(0xFFF0F0F0), width: 1),
          ),
          child: Column(
            children: List.generate(g.transactions.length * 2 - 1, (i) {
              if (i.isOdd) return Divider(color: t.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1, indent: 62, endIndent: 14);
              final tx = g.transactions[i ~/ 2];
              return RecentActivityItemCard(
                transaction: tx,
                onTap: (t) => AddTransactionSheet.show(context: context, isIncome: t.isIncome, transaction: t),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.s24),
      ],
    );
  }

  List<_DateGroup> _groupByDate(List<TransactionItem> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final fmt = DateFormat('dd MMM yyyy');
    final map = <DateTime, List<TransactionItem>>{};

    for (final tx in transactions) {
      final day = DateTime(tx.dateTime.year, tx.dateTime.month, tx.dateTime.day);
      map.putIfAbsent(day, () => []).add(tx);
    }

    final sortedDays = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedDays.map((day) {
      final label = day == today ? 'Today' : day == yesterday ? 'Yesterday' : fmt.format(day);
      return _DateGroup(label, map[day]!);
    }).toList();
  }
}

class _DateGroup {
  final String dateLabel;
  final List<TransactionItem> transactions;
  _DateGroup(this.dateLabel, this.transactions);
}
