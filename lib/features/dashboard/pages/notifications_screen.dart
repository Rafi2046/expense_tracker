import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  List<NotificationItem> _getFilteredNotifications(List<NotificationItem> notifications) {
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

  void _showNotificationDetails(BuildContext context, NotificationItem item, NotificationProvider provider) {
    provider.markAsRead(item.id);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          item.description,
          style: GoogleFonts.workSans(fontSize: 14, color: AppColors.loginTitle, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold, color: AppColors.buttonColor),
            ),
          ),
        ],
      ),
    );
  }

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
        return Icons.warning_amber_rounded;
      case NotificationType.credit:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.update:
        return Icons.auto_awesome_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final allNotifications = provider.notifications;
    final filtered = _getFilteredNotifications(allNotifications);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                'Mark read',
                style: GoogleFonts.workSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.activeGreen,
                  fontSize: 14,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          if (allNotifications.isNotEmpty)
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Alerts'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Updates'),
                ],
              ),
            ),

          // Notifications List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? const NotificationEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: AppColors.activeRed),
                        ),
                        onDismissed: (direction) {
                          provider.deleteNotification(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notification "${item.title}" dismissed'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  provider.insertNotification(index, item);
                                },
                              ),
                            ),
                          );
                        },
                        child: NotificationCard(
                          item: item,
                          onTap: () => _showNotificationDetails(context, item, provider),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppColors.buttonColor.withValues(alpha: 0.15),
      backgroundColor: Colors.grey.shade100,
      labelStyle: GoogleFonts.workSans(
        color: isSelected ? AppColors.buttonColor : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.buttonColor.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}
