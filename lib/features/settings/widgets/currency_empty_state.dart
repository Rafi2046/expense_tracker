import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';

class CurrencyEmptyState extends StatelessWidget {
  const CurrencyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Text(
          'No currencies found',
          style: AppTextStyles.reportTileTitle.copyWith(
            color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
