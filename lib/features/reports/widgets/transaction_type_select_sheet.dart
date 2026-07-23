import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class TransactionTypeSelectSheet extends StatelessWidget {
  final String selectedType;

  const TransactionTypeSelectSheet({
    super.key,
    required this.selectedType,
  });

  static Future<String?> show(
    BuildContext context, {
    required String selectedType,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionTypeSelectSheet(
        selectedType: selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final types = [
      'All Transactions',
      'Payment In',
      'Payment Out',
      'Expense',
      'Income',
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.r24),
          topRight: Radius.circular(AppSpacing.r24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.p8, bottom: AppSpacing.p8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSpacing.r12),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
            child: Text(
              context.translate('select_transaction_type'),
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),

          // Options List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: types.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.dividerTheme.color ?? const Color(0xFFF8FAFC),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final type = types[index];
              final isSelected = selectedType == type;

              return ListTile(
                onTap: () => Navigator.pop(context, type),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p4),
                title: Text(
                  (() {
                    if (type == 'All Transactions') return context.translate('all_transactions');
                    if (type == 'Payment In') return context.translate('payment_in');
                    if (type == 'Payment Out') return context.translate('payment_out');
                    if (type == 'Expense') return context.translate('expense');
                    if (type == 'Income') return context.translate('income');
                    return type;
                  })(),
                  style: AppTextStyles.bodyBold.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                trailing: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? theme.primaryColor : (isDark ? Colors.white24 : Colors.grey.shade300),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
