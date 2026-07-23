import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class ExpenseTimeFrameSelector extends StatelessWidget {
  final List<String> timeFrames;
  final String selectedTimeFrame;
  final Function(String) onTimeFrameChanged;

  const ExpenseTimeFrameSelector({
    super.key,
    required this.timeFrames,
    required this.selectedTimeFrame,
    required this.onTimeFrameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeFrames.map((tf) {
          final isSelected = tf == selectedTimeFrame;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.p12),
            child: GestureDetector(
              onTap: () => onTimeFrameChanged(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p16,
                  vertical: AppSpacing.p8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.expensePink
                      : (isDark ? Colors.white12 : AppColors.chipBackground),
                  borderRadius: BorderRadius.circular(AppSpacing.r8),
                ),
                child: Text(
                  context.translate(tf.toLowerCase()),
                  style: AppTextStyles.body.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontFamily: TextStyle().fontFamily,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
