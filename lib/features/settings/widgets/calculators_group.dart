import 'package:expense_tracker/features/calculators/pages/emi_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/interest_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/tax_calculator_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CalculatorsGroup extends StatelessWidget {
  const CalculatorsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: context.translate('calculators'),
      children: [
        // EMI Calculator
        SettingsOptionRow(
          icon: LucideIcons.calculator,
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
          icon: LucideIcons.percent,
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
          icon: LucideIcons.receipt,
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
