import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

Future<bool> showDeleteTourDialog(BuildContext context, String tourName, {bool isOwner = true}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      title: Text(
        ctx.translate(isOwner ? 'delete_tour' : 'leave_tour'),
        style: AppTextStyles.h2.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ctx.translate(isOwner ? 'this_action_cannot_be_undone' : 'confirm_leave_tour_msg'),
            style: AppTextStyles.profileSubtitle.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tourName,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            ctx.translate(isOwner ? 'delete' : 'leave_tour'),
            style: AppTextStyles.label.copyWith(
              color: const Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
