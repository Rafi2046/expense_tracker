import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TourCurrencySelector extends StatelessWidget {
  final ThemeData theme;
  final String value;
  final ValueChanged<String> onChanged;

  const TourCurrencySelector({
    super.key,
    required this.theme,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.12);
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: context.translate('currency'),
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.r12),
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
      ),
      dropdownColor: theme.colorScheme.surface,
      items: const [
        DropdownMenuItem(value: 'USD', child: Text('\$ USD')),
        DropdownMenuItem(value: 'BDT', child: Text('৳ BDT')),
        DropdownMenuItem(value: 'EUR', child: Text('€ EUR')),
        DropdownMenuItem(value: 'GBP', child: Text('£ GBP')),
        DropdownMenuItem(value: 'INR', child: Text('₹ INR')),
        DropdownMenuItem(value: 'JPY', child: Text('¥ JPY')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      style: AppTextStyles.reportTileTitle.copyWith(
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}
