import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class ErrorDialog extends StatelessWidget {
  final String messageKey;

  const ErrorDialog({super.key, required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r16)),
      title: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: AppColors.activeRed),
          const SizedBox(width: AppSpacing.w8),
          Text(
            context.translate('missing_info'),
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(context.translate(messageKey), style: AppTextStyles.h3),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.translate('ok'),
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
