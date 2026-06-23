import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('time_period'),
          style: AppTextStyles.calculatorLabel,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F1F1), width: 1.0),
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.calculatorInputText,
                  decoration: InputDecoration(
                    hintText: context.translate('time_period'),
                    hintStyle: AppTextStyles.textFieldHint.copyWith(color: Colors.grey.shade400),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F1F1), width: 1.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: unit,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: themeColor),
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
                            child: Text(displayVal),
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
