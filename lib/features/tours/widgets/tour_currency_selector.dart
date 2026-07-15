import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: context.translate('currency'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
