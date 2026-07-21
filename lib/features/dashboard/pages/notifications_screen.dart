import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/pages/notification_details_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_empty_state.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final allNotifications = provider.notifications;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalCount = allNotifications.length;
    final unreadCount = allNotifications.where((n) => !n.isRead).length;
    final readCount = totalCount - unreadCount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon:
              Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('notifications'),
          style:
              AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                context.translate('mark_read'),
                style: AppTextStyles.bodyBold
                    .copyWith(color: AppColors.activeGreen),
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
      body: provider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color:
                    isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor,
              ),
            )
          : Column(
              children: [
                if (allNotifications.isNotEmpty) ...[
                  _buildSummaryRow(
                    isDark: isDark,
                    total: totalCount,
                    unread: unreadCount,
                    read: readCount,
                  ),
                  const SizedBox(height: 4),
                ],
                Expanded(
                  child: allNotifications.isEmpty
                      ? const NotificationEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: allNotifications.length,
                          itemBuilder: (context, index) {
                            final item = allNotifications[index];
                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.trash2,
                                  color: AppColors.activeRed,
                                  size: 20,
                                ),
                              ),
                              onDismissed: (_) {
                                provider.deleteNotification(item.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.translate('notification_dismissed'),
                                    ),
                                    action: SnackBarAction(
                                      label: context.translate('undo'),
                                      textColor: AppColors.activeGreen,
                                      onPressed: () {
                                        provider.insertNotification(index, item);
                                      },
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              child: NotificationCard(
                                item: item,
                                onTap: () {
                                  context.read<NotificationProvider>().markAsRead(item.id);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotificationDetailsScreen(
                                          item: item),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow({
    required bool isDark,
    required int total,
    required int unread,
    required int read,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: context.translate('total'),
              count: total,
              icon: LucideIcons.bell,
              iconColor: Colors.blueAccent,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: context.translate('unread'),
              count: unread,
              icon: LucideIcons.mail,
              iconColor: Colors.orange,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: context.translate('read'),
              count: read,
              icon: LucideIcons.mailCheck,
              iconColor: AppColors.activeGreen,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22262E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: AppFontSizes.size18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade500 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
