import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/utils/notification_localizer.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Color _getTypeColor(NotificationType type) {
  switch (type) {
    case NotificationType.alert:
      return AppColors.activeRed;
    case NotificationType.credit:
      return AppColors.activeGreen;
    case NotificationType.update:
      return AppColors.buttonColor;
    case NotificationType.system:
      return Colors.blueAccent;
  }
}

IconData _getTypeIcon(NotificationType type) {
  switch (type) {
    case NotificationType.alert:
      return LucideIcons.alertTriangle;
    case NotificationType.credit:
      return LucideIcons.wallet;
    case NotificationType.update:
      return LucideIcons.sparkles;
    case NotificationType.system:
      return LucideIcons.info;
  }
}

Future<void> showNotificationDetails(
  BuildContext context,
  NotificationItem item,
  NotificationProvider provider,
) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final displayTitle = NotificationLocalizer.resolveTitle(context, item);
  final displayBody = NotificationLocalizer.resolveBody(context, item);
  provider.markAsRead(item.id);
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayTitle,
              style: AppTextStyles.h3
                  .copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
      content: Text(
        displayBody,
        style: AppTextStyles.body.copyWith(
          color: isDark ? Colors.grey.shade300 : AppColors.loginTitle,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            context.translate('close'),
            style: AppTextStyles.bodyBold.copyWith(
              color: isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor,
            ),
          ),
        ),
      ],
    ),
  );
}
