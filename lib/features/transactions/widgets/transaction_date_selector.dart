import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TransactionDateSelector extends StatelessWidget {
  final TransactionProvider provider;
  final bool isDark;

  const TransactionDateSelector({
    super.key,
    required this.provider,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final date = provider.selectedDate;
    final period = provider.selectedPeriod;

    String label;
    if (period == TransactionPeriod.daily) {
      final today = DateTime.now();
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        label = "Today (${DateFormat('d MMM yyyy').format(date)})";
      } else {
        label = DateFormat('d MMMM yyyy').format(date);
      }
    } else {
      label = DateFormat('yyyy').format(date);
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (period == TransactionPeriod.daily) {
                provider.setSelectedDate(date.subtract(const Duration(days: 1)));
              } else {
                provider.setSelectedDate(DateTime(date.year - 1, date.month, date.day));
              }
            },
          ),
          GestureDetector(
            onTap: () async {
              if (period == TransactionPeriod.daily) {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  provider.setSelectedDate(picked);
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  period == TransactionPeriod.daily ? Icons.calendar_today : Icons.calendar_month,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              if (period == TransactionPeriod.daily) {
                provider.setSelectedDate(date.add(const Duration(days: 1)));
              } else {
                provider.setSelectedDate(DateTime(date.year + 1, date.month, date.day));
              }
            },
          ),
        ],
      ),
    );
  }
}
