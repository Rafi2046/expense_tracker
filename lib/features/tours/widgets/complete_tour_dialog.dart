import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


Future<bool> showCompleteTourDialog(BuildContext context, String tourName, bool isCompleted) async {
  final theme = Theme.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.r16),
      ),
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        isCompleted
            ? ctx.translate('mark_as_active')
            : ctx.translate('mark_as_completed'),
        style: AppTextStyles.dialogTitle.copyWith(color: theme.colorScheme.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCompleted
                ? 'Are you sure you want to mark this tour as active?'
                : 'Are you sure you want to mark this tour as completed?',
            style: AppTextStyles.dialogBody.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            tourName,
            style: AppTextStyles.bodyBold.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            ctx.translate('cancel'),
            style: AppTextStyles.label.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            isCompleted
                ? ctx.translate('mark_as_active')
                : ctx.translate('mark_as_completed'),
            style: AppTextStyles.label.copyWith(
              color: AppColors.activeGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
