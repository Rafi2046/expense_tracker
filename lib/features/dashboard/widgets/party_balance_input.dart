import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartyBalanceInput extends StatelessWidget {
  final TextEditingController balanceController;
  final TextEditingController dateController;
  final String currencySymbol;
  final VoidCallback onSelectDate;

  const PartyBalanceInput({
    super.key,
    required this.balanceController,
    required this.dateController,
    required this.currencySymbol,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: balanceController,
            style: AppTextStyles.partyFormInput.copyWith(color: theme.colorScheme.onSurface),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: context.translate('opening_balance'),
              hintStyle: AppTextStyles.partyFormHint.copyWith(color: isDark ? Colors.white30 : null),
              prefixText: '$currencySymbol ',
              prefixStyle: AppTextStyles.partyFormInput.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: dateController,
            readOnly: true,
            style: AppTextStyles.partyFormInput.copyWith(
              fontSize: AppFontSizes.size12,
              color: theme.colorScheme.onSurface,
            ),
            onTap: onSelectDate,
            decoration: InputDecoration(
              labelText: context.translate('as_of_date'),
              labelStyle: AppTextStyles.partyFormLabel.copyWith(
                fontSize: AppFontSizes.size12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: theme.cardColor,
              suffixIcon: Icon(
                LucideIcons.calendar,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                size: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
