import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/reports/models/report_item.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportTile extends StatelessWidget {
  final ReportItem item;

  const ReportTile({
    super.key,
    required this.item,
  });

  void _pushReport(BuildContext context) {
    if (item.titleKey == 'weekly_summary') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => item.destination),
      );
    } else {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => item.destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _pushReport(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: theme.primaryColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.translate(item.titleKey),
                    style: AppTextStyles.bodyBold.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.translate(item.subtitleKey),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? Colors.white60 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.arrowRight,
                size: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
