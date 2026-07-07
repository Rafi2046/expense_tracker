import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LedgerMonthSelector extends StatefulWidget {
  const LedgerMonthSelector({super.key});

  @override
  State<LedgerMonthSelector> createState() => _LedgerMonthSelectorState();
}

class _LedgerMonthSelectorState extends State<LedgerMonthSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to the selected month after the widget finishes building
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

    // Item width is 68 + 10 (margin) = 78
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            final activeOption = provider.sortOption;

             Widget buildSortItem(String title, TransactionSortOption option, IconData icon) {
              final isSelected = activeOption == option;
              final accentColor = const Color(0xFF6A53A1); // premium purple/violet accent
              final isDarkItem = Theme.of(context).brightness == Brightness.dark;

              return InkWell(
                onTap: () {
                  provider.updateSortOption(option);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor.withValues(alpha: 0.05) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? accentColor : (isDarkItem ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Symbols.check_circle_rounded,
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
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
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate('sort_transactions'),
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                            Symbols.close,
                            size: 18,
                            color: isDarkSheet ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Options list
                  buildSortItem(context.translate('sort_latest'), TransactionSortOption.latest, Symbols.calendar_today_rounded),
                  const SizedBox(height: 12),
                  buildSortItem(context.translate('sort_amount_high_low'), TransactionSortOption.amountHighToLow, Symbols.trending_down_rounded),
                  const SizedBox(height: 12),
                  buildSortItem(context.translate('sort_amount_low_high'), TransactionSortOption.amountLowToHigh, Symbols.trending_up_rounded),
                  const SizedBox(height: 12),
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

    // Listen to changes to index and auto scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedMonth());

    return Row(
      children: [
        // Horizontal calendar slider
        Expanded(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final month = months[index];
                final isSelected = index == selectedIndex;
                final isCurrent = index == 6;

                final isDarkSlider = Theme.of(context).brightness == Brightness.dark;

                return GestureDetector(
                  onTap: () {
                    provider.selectMonthIndex(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF4A3482), Color(0xFF6A53A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : isCurrent
                              ? (isDarkSlider ? Colors.grey.shade800 : const Color(0xFFECEFF1))
                              : (isDarkSlider ? Theme.of(context).cardColor : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : isCurrent
                                ? (isDarkSlider ? Colors.grey.shade700 : const Color(0xFFCFD8DC))
                                : (isDarkSlider
                                    ? (Theme.of(context).dividerTheme.color ?? const Color(0xFF2D2D2D))
                                    : const Color(0xFFF1F1F1)),
                        width: 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6A53A1).withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM', locale).format(month).toUpperCase(),
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : (isDarkSlider ? Colors.white70 : Colors.black87),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          DateFormat('yyyy', locale).format(month),
                          style: GoogleFonts.workSans(
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected ? Colors.white70 : (isDarkSlider ? Colors.grey.shade400 : Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),

        // Filter button
        Container(
          width: 44,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? (Theme.of(context).dividerTheme.color ?? const Color(0xFF2D2D2D))
                  : const Color(0xFFF1F1F1),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Symbols.tune_rounded, size: 18),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF31394D),
            onPressed: () => _showSortBottomSheet(context),
          ),
        ),
      ],
    );
  }
}
