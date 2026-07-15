import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ErrorDialog extends StatelessWidget {
  final String messageKey;

  const ErrorDialog({super.key, required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: AppColors.activeRed),
          const SizedBox(width: AppSpacing.w8),
          Text(
            context.translate('missing_info'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.size18,
            ),
          ),
        ],
      ),
      content: Text(context.translate(messageKey), style: TextStyle(fontSize: AppFontSizes.size16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.translate('ok'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.size16,
            ),
          ),
        ),
      ],
    );
  }
}
