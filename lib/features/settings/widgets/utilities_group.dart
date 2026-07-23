import 'package:expense_tracker/features/notes/pages/notebook_screen.dart';
import 'package:expense_tracker/features/calculators/pages/emi_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/interest_calculator_screen.dart';
import 'package:expense_tracker/features/calculators/pages/tax_calculator_screen.dart';
import 'package:expense_tracker/features/settings/widgets/settings_group_card.dart';
import 'package:expense_tracker/features/settings/widgets/settings_option_row.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


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
          icon: LucideIcons.book,
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
          icon: LucideIcons.calculator,
          title: context.translate('calculators'),
          trailingIcon: _isCalculatorsExpanded
              ? LucideIcons.chevronDown
              : LucideIcons.chevronRight,
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
                padding: const EdgeInsets.only(left: AppSpacing.p16),
                child: SettingsOptionRow(
                  icon: LucideIcons.pieChart,
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
                padding: const EdgeInsets.only(left: AppSpacing.p16),
                child: SettingsOptionRow(
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
              ),

              // Tax Calculator
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.p16),
                child: SettingsOptionRow(
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
