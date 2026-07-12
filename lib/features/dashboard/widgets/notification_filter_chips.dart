import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class NotificationFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const NotificationFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor;

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: ['All', 'Alerts', 'Updates'].map((label) {
          final isSelected = selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(context.translate(label.toLowerCase())),
              selected: isSelected,
              onSelected: (val) {
                if (val) onFilterChanged(label);
              },
              selectedColor: primaryColor.withValues(alpha: 0.15),
              backgroundColor:
                  isDark ? theme.cardColor : Colors.grey.shade100,
              labelStyle: AppTextStyles.label
                  .copyWith(fontSize: AppFontSizes.size13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
