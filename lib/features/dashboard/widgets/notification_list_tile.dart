import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;

  const NotificationListTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          LucideIcons.trash,
          color: AppColors.activeRed,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: NotificationCard(item: item, onTap: onTap),
    );
  }
}
