import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class InterestFrequencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const InterestFrequencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final list = ['Monthly', 'Quarterly', 'Half-Yearly', 'Yearly'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.translate('compounding_frequency'),
            style: AppTextStyles.calculatorLabel,
          ),
          DropdownButton<String>(
            value: value,
            underline: Container(),
            elevation: 2,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6A53A1)),
            style: AppTextStyles.calculatorLabel.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6A53A1),
            ),
            items: list.map<DropdownMenuItem<String>>((String val) {
              String displayVal = val;
              switch (val) {
                case 'Monthly':
                  displayVal = context.translate('frequency_monthly');
                  break;
                case 'Quarterly':
                  displayVal = context.translate('frequency_quarterly');
                  break;
                case 'Half-Yearly':
                  displayVal = context.translate('frequency_half_yearly');
                  break;
                case 'Yearly':
                  displayVal = context.translate('frequency_yearly');
                  break;
              }
              return DropdownMenuItem<String>(
                value: val,
                child: Text(displayVal),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
