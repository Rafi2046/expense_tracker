import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

class WeekdayHeadings extends StatelessWidget {
  const WeekdayHeadings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          context.translate('weekday_sun'),
          context.translate('weekday_mon'),
          context.translate('weekday_tue'),
          context.translate('weekday_wed'),
          context.translate('weekday_thu'),
          context.translate('weekday_fri'),
          context.translate('weekday_sat'),
        ].map((day) {
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
