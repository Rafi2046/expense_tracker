import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class TimeFrameSelector extends StatelessWidget {
  final List<String> timeFrames;
  final String selectedTimeFrame;
  final Function(String) onTimeFrameChanged;

  const TimeFrameSelector({
    super.key,
    required this.timeFrames,
    required this.selectedTimeFrame,
    required this.onTimeFrameChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.dividerColor, width: 1.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: timeFrames.map((tf) {
          final isSelected = tf == selectedTimeFrame;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTimeFrameChanged(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  context.translate(tf.toLowerCase()),
                  style: isSelected
                      ? AppTextStyles.timeFrameSelectedText
                      : AppTextStyles.timeFrameUnselectedText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
