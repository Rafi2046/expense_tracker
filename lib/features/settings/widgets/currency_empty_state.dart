import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class CurrencyEmptyState extends StatelessWidget {
  const CurrencyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p40),
      child: Center(
        child: Text(
          context.translate('no_currencies_found'),
          style: AppTextStyles.reportTileTitle.copyWith(
            color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
