import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LedgerMonthSelector extends StatelessWidget {
  const LedgerMonthSelector({super.key});

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
                          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 16,
                          color: isSelected ? accentColor : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? accentColor : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                        color: Colors.grey.shade300,
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
                        'Sort Transactions',
                        style: GoogleFonts.workSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Options list
                  buildSortItem('Latest', TransactionSortOption.latest, Icons.calendar_today_rounded),
                  const SizedBox(height: 12),
                  buildSortItem('Amount: High to Low', TransactionSortOption.amountHighToLow, Icons.trending_down_rounded),
                  const SizedBox(height: 12),
                  buildSortItem('Amount: Low to High', TransactionSortOption.amountLowToHigh, Icons.trending_up_rounded),
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
    final months = provider.availableMonths;
    final selectedIndex = provider.selectedMonthIndex;
    final selectedMonth = provider.selectedMonth;

    return Row(
      children: [
        // Month Selector Card
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              border: Border.all(
                color: const Color(0xFFF1F1F1),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    size: 22,
                  ),
                  color: selectedIndex > 0 ? Colors.black87 : Colors.grey.shade300,
                  onPressed: selectedIndex > 0
                      ? () => provider.selectMonthIndex(selectedIndex - 1)
                      : null,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(selectedMonth),
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                  ),
                  color: selectedIndex < months.length - 1
                      ? Colors.black87
                      : Colors.grey.shade300,
                  onPressed: selectedIndex < months.length - 1
                      ? () => provider.selectMonthIndex(selectedIndex + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),

        // Filter Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.br12),
            border: Border.all(
              color: const Color(0xFFF1F1F1),
              width: 1.0,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            color: const Color(0xFF31394D),
            onPressed: () => _showSortBottomSheet(context),
          ),
        ),
      ],
    );
  }
}
