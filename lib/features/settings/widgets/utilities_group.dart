import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/features/notes/pages/notebook_screen.dart';
import 'package:expense_tracker/features/calculators/pages/emi_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/interest_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/tax_calculator_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';

class UtilitiesGroup extends StatefulWidget {
  const UtilitiesGroup({super.key});

  @override
  State<UtilitiesGroup> createState() => _UtilitiesGroupState();
}

class _UtilitiesGroupState extends State<UtilitiesGroup> {
  bool _isCalculatorsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SettingsGroupCard(
      title: context.translate('utilities'),
      children: [
        // Notebook
        SettingsOptionRow(
          icon: Symbols.book_rounded,
          iconBgColor: const Color(0xFFEFEBE9),
          iconColor: const Color(0xFF6D4C41),
          title: context.translate('notebook'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotebookScreen(),
              ),
            );
          },
        ),

        // Collapsible Calculators Header Row
        SettingsOptionRow(
          icon: Symbols.calculate_rounded,
          iconBgColor: const Color(0xFFE6F3EE),
          iconColor: const Color(0xFF006C49),
          title: context.translate('calculators'),
          trailingIcon: _isCalculatorsExpanded
              ? Symbols.keyboard_arrow_down_rounded
              : Symbols.keyboard_arrow_right_rounded,
          onTap: () {
            setState(() {
              _isCalculatorsExpanded = !_isCalculatorsExpanded;
            });
          },
        ),

        // Sub-sections dropdown list
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              // EMI Calculator
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SettingsOptionRow(
                  icon: Symbols.pie_chart_outline_rounded,
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
              ),

              // Interest Calculator
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SettingsOptionRow(
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
              ),

              // Tax Calculator
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SettingsOptionRow(
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
              ),
            ],
          ),
          crossFadeState: _isCalculatorsExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
