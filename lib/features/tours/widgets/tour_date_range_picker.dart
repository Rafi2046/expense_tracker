import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class TourDateRangePicker extends StatelessWidget {
  final ThemeData theme;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;

  const TourDateRangePicker({
    super.key,
    required this.theme,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
  });

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final alpha = isDark ? 0.3 : 0.1;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Duration',
            style: AppTextStyles.reportTileTitle.copyWith(
              fontWeight: FontWeight.w400,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Start',
                  dateText: _formatDate(startDate),
                  icon: LucideIcons.calendarDays,
                  onTap: onPickStartDate,
                  textColor: textColor,
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(LucideIcons.arrowRight,
                  size: 18,
                  color: textColor.withValues(alpha: alpha),
                ),
              ),
              Expanded(
                child: _DateButton(
                  label: 'End',
                  dateText: _formatDate(endDate),
                  icon: LucideIcons.calendarCheck,
                  onTap: onPickEndDate,
                  textColor: textColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String dateText;
  final IconData icon;
  final VoidCallback onTap;
  final Color textColor;
  final bool isDark;

  const _DateButton({
    required this.label,
    required this.dateText,
    required this.icon,
    required this.onTap,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: textColor.withValues(alpha: 0.5)),
            const SizedBox(height: 4),
            Text(dateText,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
