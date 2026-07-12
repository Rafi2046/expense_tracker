import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
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

  void _showSortBottomSheet(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final activeOption = provider.sortOption;

            Widget buildSortItem(String title, TransactionSortOption option, IconData icon) {
              final isSelected = activeOption == option;
              final accentColor = const Color(0xFF6A53A1);
              final isDarkItem = Theme.of(context).brightness == Brightness.dark;

              return InkWell(
                onTap: () {
                  provider.updateSortOption(option);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor.withValues(alpha: 0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.1)
                              : (isDarkItem ? Colors.grey.shade800 : Colors.grey.shade100),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 16,
                          color: isSelected ? accentColor : (isDarkItem ? Colors.white60 : Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyBold.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? accentColor : (isDarkItem ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          LucideIcons.checkCircle,
                          color: accentColor,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }

            final isDarkSheet = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDarkSheet ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('sort_transactions'),
                        style: AppTextStyles.sectionHeaderTitle.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDarkSheet ? Colors.grey.shade800 : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.x,
                            size: 18,
                            color: isDarkSheet ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildSortItem(context.translate('sort_latest'), TransactionSortOption.latest, LucideIcons.calendar),
                  const SizedBox(height: 8),
                  buildSortItem(context.translate('sort_amount_high_low'), TransactionSortOption.amountHighToLow, LucideIcons.trendingDown),
                  const SizedBox(height: 8),
                  buildSortItem(context.translate('sort_amount_low_high'), TransactionSortOption.amountLowToHigh, LucideIcons.trendingUp),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
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
      onFilterTap: () => _showSortBottomSheet(context),
    );
  }
}
