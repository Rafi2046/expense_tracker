import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class WeekdayHeadings extends StatelessWidget {
  const WeekdayHeadings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
          return SizedBox(
            width: 40,
            child: Center(
              child: Text(
                day,
                style: AppTextStyles.label.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
