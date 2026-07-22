import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/notification_provider.dart';
import 'package:expense_tracker/core/utils/notification_localizer.dart';
import 'package:expense_tracker/features/dashboard/pages/weekly_summary_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/daily_summary_screen.dart';
import 'package:expense_tracker/features/dashboard/pages/monthly_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailsScreen({super.key, required this.item});

  String _ago(BuildContext context, DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return context.translate('just_now');
    if (diff.inHours < 1) {
      final m = diff.inMinutes;
      return '$m ${context.translate('mins_ago')}';
    }
    if (diff.inDays < 1) {
      final h = diff.inHours;
      return '$h ${context.translate('hours_ago')}';
    }
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final w = diff.inDays ~/ 7;
    return '$w ${context.translate('weeks_ago')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final cardBorder = Border.all(color: Colors.white.withValues(alpha: 0.1));
    final cardRadius = BorderRadius.circular(12);
    final sectionGap = 24.0;

    final displayTitle = NotificationLocalizer.resolveTitle(context, item);
    final displayBody = NotificationLocalizer.resolveBody(context, item);

    final isWeekly = item.id.startsWith('weekly_summary_');
    final isDaily = item.id.startsWith('daily_summary_');
    final isMonthly = item.id.startsWith('monthly_summary_');
    final isInteractiveSummary = isWeekly || isDaily || isMonthly;

    Widget sectionLabel(String text) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    Widget valueText(String text, {bool bold = false}) {
      return Text(
        text,
        style: TextStyle(
          fontSize: bold ? 16 : 15,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: theme.colorScheme.onSurface,
          height: bold ? null : 1.5,
        ),
      );
    }

    Widget metaRow(String label, String value) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final statusText = item.isRead
        ? context.translate('read')
        : context.translate('unread');

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
          context.translate('notification_details'),
          style:
              AppTextStyles.h2.copyWith(color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title Section ──
            sectionLabel(context.translate('title_label')),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                border: cardBorder,
                borderRadius: cardRadius,
              ),
              child: valueText(displayTitle, bold: true),
            ),
            SizedBox(height: sectionGap),

            // ── Message Section ──
            sectionLabel(context.translate('message_label')),
            InkWell(
              onTap: isWeekly
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeeklySummaryScreen(),
                        ),
                      );
                    }
                  : isDaily
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DailySummaryScreen(),
                            ),
                          );
                        }
                      : isMonthly
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MonthlySummaryScreen(),
                                ),
                              );
                            }
                          : null,
              borderRadius: cardRadius,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: isInteractiveSummary
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF8E75C8).withValues(alpha: 0.5)
                              : AppColors.buttonColor.withValues(alpha: 0.3),
                          width: 1.5,
                        )
                      : cardBorder,
                  borderRadius: cardRadius,
                  boxShadow: isInteractiveSummary
                      ? [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF8E75C8)
                                    : AppColors.buttonColor)
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    valueText(displayBody),
                    if (isInteractiveSummary) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.translate('tap_now'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFF8E75C8)
                                  : AppColors.buttonColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.arrowRight,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF8E75C8)
                                : AppColors.buttonColor,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: sectionGap),

            // ── Metadata Section (no label) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                border: cardBorder,
                borderRadius: cardRadius,
              ),
              child: Column(
                children: [
                  metaRow(
                    context.translate('created_at_label'),
                    _ago(context, item.dateTime),
                  ),
                  metaRow(
                    context.translate('status_label'),
                    statusText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
