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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.dividerColor, width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(title, style: AppTextStyles.sectionHeaderTitle),
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
            color: AppColors.dividerColor.withValues(alpha: 0.5),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: AppColors.dividerColor.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) => children[index],
          ),
        ],
      ),
    );
  }
}
