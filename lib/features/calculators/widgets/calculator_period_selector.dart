import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CalculatorPeriodSelector extends StatelessWidget {
  final TextEditingController controller;
  final String unit;
  final ValueChanged<String?> onChanged;
  final Color themeColor;

  const CalculatorPeriodSelector({
    super.key,
    required this.controller,
    required this.unit,
    required this.onChanged,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('time_period'),
          style: AppTextStyles.calculatorLabel.copyWith(color: isDark ? Colors.grey.shade400 : null),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.calculatorInputText.copyWith(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: context.translate('time_period'),
                    hintStyle: AppTextStyles.textFieldHint.copyWith(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: unit,
                    isExpanded: true,
                    dropdownColor: theme.cardColor,
                    icon: Icon(LucideIcons.chevronDown, color: themeColor),
                    style: AppTextStyles.calculatorLabel.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                    items: ['Day', 'Week', 'Month', 'Quarter', 'Year']
                        .map((String val) {
                          String displayVal = val;
                          switch (val) {
                            case 'Day':
                              displayVal = context.translate('day_unit');
                              break;
                            case 'Week':
                              displayVal = context.translate('week_unit');
                              break;
                            case 'Month':
                              displayVal = context.translate('month_unit');
                              break;
                            case 'Quarter':
                              displayVal = context.translate('quarter_unit');
                              break;
                            case 'Year':
                              displayVal = context.translate('year_unit');
                              break;
                          }
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(
                              displayVal,
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          );
                        })
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
