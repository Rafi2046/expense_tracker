import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'month_selector_header.dart';

class TransactionsMonthSelector extends StatefulWidget {
  const TransactionsMonthSelector({super.key});

  @override
  State<TransactionsMonthSelector> createState() => _TransactionsMonthSelectorState();
}

class _TransactionsMonthSelectorState extends State<TransactionsMonthSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedMonth(animate: false));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedMonth({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final index = provider.selectedMonthIndex;

    final targetOffset = (index * 78.0) - (MediaQuery.of(context).size.width / 2) + 39.0;
    final clampedOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final locale = context.watch<LanguageProvider>().currentLanguageCode;
    final months = provider.availableMonths;
    final selectedIndex = provider.selectedMonthIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedMonth());

    return MonthSelectorHeader(
      scrollController: _scrollController,
      months: months,
      selectedIndex: selectedIndex,
      locale: locale,
      onMonthTap: (index) => provider.selectMonthIndex(index),
    );
  }
}
