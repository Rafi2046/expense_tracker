import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/features/calculators/pages/emi_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/interest_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/tax_calculator_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class CalculatorsGroup extends StatelessWidget {
  const CalculatorsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: context.translate('calculators'),
      children: [
        // EMI Calculator
        SettingsOptionRow(
          icon: Symbols.calculate_rounded,
          iconBgColor: const Color(0xFFE6F3EE),
          iconColor: const Color(0xFF006C49),
          title: context.translate('emi_calculator'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmiCalculatorScreen(),
              ),
            );
          },
        ),

        // Interest Calculator
        SettingsOptionRow(
          icon: Symbols.percent_rounded,
          iconBgColor: const Color(0xFFF3EFFF),
          iconColor: const Color(0xFF6A53A1),
          title: context.translate('interest_calculator'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InterestCalculatorScreen(),
              ),
            );
          },
        ),

        // Tax Calculator
        SettingsOptionRow(
          icon: Symbols.receipt_long_rounded,
          iconBgColor: const Color(0xFFFDECEC),
          iconColor: const Color(0xFFD9383A),
          title: context.translate('tax_calculator'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaxCalculatorScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
