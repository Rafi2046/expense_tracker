import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/utils/notification_localizer.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationCard({super.key, required this.item, required this.onTap});

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
        return LucideIcons.bell;
      case NotificationType.credit:
        return LucideIcons.wallet;
      case NotificationType.update:
        return LucideIcons.refreshCw;
      case NotificationType.system:
        return LucideIcons.settings;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor(item.type);
    final typeIcon = _getTypeIcon(item.type);
    final title = NotificationLocalizer.resolveTitle(context, item);
    final body = NotificationLocalizer.resolveBody(context, item);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.p8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22262E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.r8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 18),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            _getTimeAgo(item.dateTime),
                            style: AppTextStyles.caption.copyWith(color: isDark
                                  ? Colors.grey.shade500
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(color: isDark
                              ? Colors.grey.shade300
                              : AppColors.loginSubTitle,
                          height: 1.3),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: AppSpacing.s8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.activeGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
