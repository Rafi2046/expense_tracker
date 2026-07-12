import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

Future<bool> showCompleteTourDialog(BuildContext context, String tourName, bool isCompleted) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      title: Text(
        isCompleted
            ? ctx.translate('mark_as_active')
            : ctx.translate('mark_as_completed'),
        style: AppTextStyles.h2,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCompleted
                ? 'Are you sure you want to mark this tour as active?'
                : 'Are you sure you want to mark this tour as completed?',
            style: AppTextStyles.profileSubtitle.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tourName,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
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
              color: const Color(0xFF6B7280),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
