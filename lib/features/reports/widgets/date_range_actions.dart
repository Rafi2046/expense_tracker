import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class DateRangeActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onApply;
  final bool canApply;
  final bool isDark;

  const DateRangeActions({
    super.key,
    required this.onCancel,
    required this.onApply,
    required this.canApply,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.activeGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
              disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            ),
            child: Text(
              'Ok',
              style: AppTextStyles.bodyBold.copyWith(
                color: canApply
                    ? Colors.white
                    : (isDark ? Colors.white24 : Colors.grey.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
