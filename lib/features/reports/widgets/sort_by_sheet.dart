import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SortBySheet extends StatelessWidget {
  final ReportSortOption currentOption;

  const SortBySheet({
    super.key,
    required this.currentOption,
  });

  static Future<ReportSortOption?> show(
    BuildContext context, {
    required ReportSortOption currentOption,
  }) {
    final theme = Theme.of(context);
    return showModalBottomSheet<ReportSortOption>(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SortBySheet(currentOption: currentOption),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child:             Text(
              context.translate('sort_by'),
            style: AppTextStyles.h3.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            ),
          ),
          Divider(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), height: 1),
          _buildOption(
            context: context,
            title: context.translate('latest_sort'),
            option: ReportSortOption.latest,
            icon: LucideIcons.arrowUpDown,
          ),
          _buildOption(
            context: context,
            title: context.translate('oldest'),
            option: ReportSortOption.oldest,
            icon: LucideIcons.arrowUpDown,
          ),
          _buildOption(
            context: context,
            title: context.translate('sort_amount_high_low'),
            option: ReportSortOption.amountHighToLow,
            icon: LucideIcons.arrowUpDown,
          ),
          _buildOption(
            context: context,
            title: context.translate('sort_amount_low_high'),
            option: ReportSortOption.amountLowToHigh,
            icon: LucideIcons.arrowUpDown,
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required ReportSortOption option,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentOption == option;

    return InkWell(
      onTap: () => Navigator.pop(context, option),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.reportTileTitle.copyWith(
                  fontSize: AppFontSizes.size14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.primaryColor : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
