import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              context.translate('cancel'),
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.activeGreen,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.activeGreen,
              disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p8),
            ),
            child: Text(
              context.translate('ok'),
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
