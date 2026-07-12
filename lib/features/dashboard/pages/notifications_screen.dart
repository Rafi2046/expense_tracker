import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_detail_dialog.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_empty_state.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_filter_chips.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  List<NotificationItem> _getFilteredNotifications(
    List<NotificationItem> notifications,
  ) {
    if (_selectedFilter == 'All') {
      return notifications;
    }
    final type = _selectedFilter == 'Alerts'
        ? NotificationType.alert
        : _selectedFilter == 'Updates'
        ? NotificationType.update
        : NotificationType.credit;
    return notifications.where((n) => n.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final allNotifications = provider.notifications;
    final filtered = _getFilteredNotifications(allNotifications);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('notifications'),
          style: AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                context.translate('mark_read'),
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.activeGreen),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          if (allNotifications.isNotEmpty)
            NotificationFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (value) => setState(() => _selectedFilter = value),
            ),

          // Notifications List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? const NotificationEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return NotificationListTile(
                        item: item,
                        onTap: () =>
                            showNotificationDetails(context, item, provider),
                        onDismissed: () {
                          provider.deleteNotification(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Notification "${item.title}" dismissed',
                              ),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  provider.insertNotification(index, item);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
