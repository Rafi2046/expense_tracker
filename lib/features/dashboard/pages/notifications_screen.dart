import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/pages/notification_details_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/notification_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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
          ? _buildShimmerSkeleton(context, isDark)
          : Column(
              children: [
                if (allNotifications.isNotEmpty) ...[
                  _buildSummaryRow(
                    isDark: isDark,
                    total: totalCount,
                    unread: unreadCount,
                    read: readCount,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                ],
                Expanded(
                  child: allNotifications.isEmpty
                      ? const NotificationEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p16,
                            vertical: AppSpacing.p8,
                          ),
                          itemCount: allNotifications.length,
                          itemBuilder: (context, index) {
                            final item = allNotifications[index];
                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppSpacing.p16),
                                margin: const EdgeInsets.only(bottom: AppSpacing.p8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(AppSpacing.r12),
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
                                        borderRadius: BorderRadius.circular(AppSpacing.r12)),
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
                                      builder: (_) => NotificationDetailsScreen(item: item),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, AppSpacing.p8),
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
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: _SummaryCard(
              label: context.translate('unread'),
              count: unread,
              icon: LucideIcons.mail,
              iconColor: Colors.orange,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
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

  Widget _buildShimmerSkeleton(BuildContext context, bool isDark) {
    final shimmerColor = isDark ? Colors.white10 : Colors.black12;
    final baseColor = isDark ? const Color(0xFF2E323E) : Colors.grey.shade200;
    final borderColor = isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.p8),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF22262E) : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              // Icon skeleton
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title skeleton
                        Container(
                          width: 120,
                          height: 12,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                          ),
                        ),
                        // Time skeleton
                        Container(
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(AppSpacing.r8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    // Description skeleton
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(AppSpacing.r8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms, color: shimmerColor);
      },
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22262E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3F4A) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '$count',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade500 : AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
