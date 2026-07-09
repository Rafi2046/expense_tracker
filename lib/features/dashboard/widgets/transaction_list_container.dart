import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class TransactionListContainer extends StatelessWidget {
  final String title;
  final Widget trailing;
  final List<Widget> children;

  const TransactionListContainer({
    super.key,
    required this.title,
    required this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : AppColors.dividerColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    title,
                    style: AppTextStyles.sectionHeaderTitle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: Align(alignment: Alignment.topRight, child: trailing),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                : AppColors.dividerColor.withValues(alpha: 0.5),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: isDark
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                  : AppColors.dividerColor.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) => children[index],
          ),
        ],
      ),
    );
  }
}
