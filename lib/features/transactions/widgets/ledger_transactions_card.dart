import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class LedgerTransactionsCard extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onFilterTap;

  const LedgerTransactionsCard({
    super.key,
    required this.children,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final List<Widget> items = [];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) {
        items.add(Container(
          color: AppColors.dividerColor.withValues(alpha: 0.3),
          height: 1.0,
        ));
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.dividerColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: onFilterTap,
                  child: Text(
                    'Filter',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.activeGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider below card header
          Container(
            color: AppColors.dividerColor.withValues(alpha: 0.3),
            height: 1.0,
          ),

          // Option list
          Column(
            children: items,
          ),
        ],
      ),
    );
  }
}
