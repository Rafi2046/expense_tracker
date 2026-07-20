import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';

String _payerNames(Map<String, double> paidBy, Map<String, String> names) {
  final resolved = <String>[];
  for (final id in paidBy.keys) {
    resolved.add(names[id] ?? 'Unknown');
  }
  if (resolved.isEmpty) return 'Unknown';
  if (resolved.length == 1) return resolved.first;
  if (resolved.length == 2) return '${resolved.first} & ${resolved.last}';
  return '${resolved.first}, ${resolved[1]} & ${resolved.last}';
}

class InvoiceLedgerWidget extends StatelessWidget {
  final List<TourExpense> expenses;
  final Map<String, String> participantNames;
  final String currency;
  final bool isDark;

  const InvoiceLedgerWidget({
    super.key,
    required this.expenses,
    required this.participantNames,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<TourExpense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            color: AppColors.activeGreen,
            child: Row(
              children: [
                _ledgerCell(context.translate('expense'), flex: 4, isHeader: true),
                _ledgerCell(context.translate('paid_by_label'), flex: 2, isHeader: true),
                _ledgerCell(context.translate('amount_label'), flex: 2, align: TextAlign.right, isHeader: true),
              ],
            ),
          ),
          ...sorted.map((e) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB))
                      .withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(formatShortDate(e.date),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppFontSizes.size9,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                _ledgerCell(_payerNames(e.paidBy, participantNames), flex: 2),
                _ledgerCell(
                  formatAmount(e.amount, currency),
                  flex: 2,
                  align: TextAlign.right,
                  bold: true,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _ledgerCell(
    String text, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    bool bold = false,
    bool isHeader = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: AppTextStyles.caption.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: isHeader
              ? Colors.white
              : (bold
                  ? (isDark ? Colors.white : const Color(0xFF111827))
                  : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280))),
        ),
      ),
    );
  }
}
