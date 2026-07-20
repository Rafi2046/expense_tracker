import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/calculators/utils/calculator_utils.dart';
import 'package:expense_tracker/features/calculators/utils/glossary_entries.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_breakdown_card.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_period_selector.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_card.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_item.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_text_field.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_type_selector.dart';
import 'package:expense_tracker/features/calculators/widgets/glossary_label.dart';
import 'package:expense_tracker/features/calculators/widgets/interest_frequency_selector.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InterestCalculatorScreen extends StatefulWidget {
  const InterestCalculatorScreen({super.key});

  @override
  State<InterestCalculatorScreen> createState() => _InterestCalculatorScreenState();
}

class _InterestCalculatorScreenState extends State<InterestCalculatorScreen> {
  late final TextEditingController _principalController;
  late final TextEditingController _rateController;
  late final TextEditingController _periodController;

  bool _isCompound = true;
  String _frequency = 'Yearly';
  String _periodUnit = 'Year';

  double _interest = 0;
  double _maturityAmount = 0;
  double _principalAmount = 0;

  @override
  void initState() {
    super.initState();
    _principalController = TextEditingController(text: '');
    _rateController = TextEditingController(text: '');
    _periodController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _recalculateSilently() {
    final String principalText = _principalController.text.trim();
    final String rateText = _rateController.text.trim();
    final String periodText = _periodController.text.trim();

    final double principal = double.tryParse(principalText) ?? 0;
    final double rate = double.tryParse(rateText) ?? 0;
    final double periodValue = double.tryParse(periodText) ?? 0;

    if (principal <= 0 || rate < 0 || periodValue <= 0) return;

    final results = CalculatorUtils.calculateInterest(
      principal: principal,
      rate: rate,
      periodValue: periodValue,
      periodUnit: _periodUnit,
      isCompound: _isCompound,
      frequency: _frequency,
    );

    setState(() {
      _interest = results['interest'] ?? 0;
      _maturityAmount = results['maturity'] ?? 0;
      _principalAmount = results['principal'] ?? 0;
    });
  }

  void _performCalculation() {
    final String principalText = _principalController.text.trim();
    final String rateText = _rateController.text.trim();
    final String periodText = _periodController.text.trim();

    if (principalText.isEmpty || rateText.isEmpty || periodText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_fill_fields', listen: false),
            style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double principal = double.tryParse(principalText) ?? 0;
    final double rate = double.tryParse(rateText) ?? 0;
    final double periodValue = double.tryParse(periodText) ?? 0;

    if (principal <= 0 || rate < 0 || periodValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_enter_valid', listen: false),
            style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final results = CalculatorUtils.calculateInterest(
      principal: principal,
      rate: rate,
      periodValue: periodValue,
      periodUnit: _periodUnit,
      isCompound: _isCompound,
      frequency: _frequency,
    );

    setState(() {
      _interest = results['interest'] ?? 0;
      _maturityAmount = results['maturity'] ?? 0;
      _principalAmount = results['principal'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final interestRatio = _maturityAmount > 0 ? (_interest / _maturityAmount) : 0.0;
    final principalRatio = _maturityAmount > 0 ? (_principalAmount / _maturityAmount) : 0.0;
    final symbol = context.currencySymbol;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryCalcColor = isDark ? const Color(0xFF8E75C8) : const Color(0xFF6A53A1);
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF1F1F1);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('interest_calculator'),
          style: AppTextStyles.calculatorTitle.copyWith(color: theme.colorScheme.onSurface),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalculatorTypeSelector(
                title1: context.translate('compound_interest'),
                title2: context.translate('simple_interest'),
                isSelected1: _isCompound,
                onTap1: () {
                  setState(() {
                    _isCompound = true;
                  });
                  _recalculateSilently();
                },
                onTap2: () {
                  setState(() {
                    _isCompound = false;
                  });
                  _recalculateSilently();
                },
              ),
              const SizedBox(height: 20),

              CalculatorResultCard(
                label: context.translate('maturity_amount'),
                value: context.formatAmount(_maturityAmount),
                gradientColors: isDark 
                    ? const [Color(0xFF4C367C), Color(0xFF8E75C8)]
                    : const [Color(0xFF6A53A1), Color(0xFF8670BE)],
                shadowColor: isDark ? const Color(0xFF4C367C) : const Color(0xFF6A53A1),
                subItems: [
                  CalculatorResultItem(title: context.translate('principal_invested'), value: context.formatAmount(_principalAmount)),
                  CalculatorResultItem(title: context.translate('interest_earned'), value: context.formatAmount(_interest)),
                ],
              ),
              const SizedBox(height: 24),

              CalculatorBreakdownCard(
                title: context.translate('investment_breakdown'),
                label1: context.translate('principal'),
                color1: primaryCalcColor,
                ratio1: principalRatio,
                label2: context.translate('interest_earned'),
                color2: isDark ? const Color(0xFF10B981) : const Color(0xFF80E2B9),
                ratio2: interestRatio,
              ),
              const SizedBox(height: 24),

              if (_isCompound) ...[
                InterestFrequencySelector(
                  value: _frequency,
                  labelWidget: GlossaryLabel(
                    text: context.translate('compounding_frequency'),
                    entry: GlossaryEntries.compoundingFrequency,
                  ),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _frequency = newValue;
                      });
                      _performCalculation();
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              CalculatorTextField(
                label: '${context.translate('principal_amount')} ($symbol)',
                labelWidget: GlossaryLabel(
                  text: context.translate('principal_amount'),
                  entry: GlossaryEntries.principal,
                ),
                hintText: context.translate('principal_amount'),
                controller: _principalController,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(symbol, style: AppTextStyles.h3.copyWith(color: primaryCalcColor)),
                ),
              ),
              const SizedBox(height: 16),

              CalculatorTextField(
                label: context.translate('annual_interest_rate'),
                labelWidget: GlossaryLabel(
                  text: context.translate('annual_interest_rate'),
                  entry: GlossaryEntries.interestRate,
                ),
                hintText: context.translate('interest'),
                controller: _rateController,
                suffix: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: Text('%', style: AppTextStyles.h3.copyWith(color: primaryCalcColor)),
                ),
              ),
              const SizedBox(height: 16),

              CalculatorPeriodSelector(
                controller: _periodController,
                unit: _periodUnit,
                themeColor: primaryCalcColor,
                labelWidget: GlossaryLabel(
                  text: context.translate('time_period'),
                  entry: GlossaryEntries.timePeriod,
                ),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setState(() {
                      _periodUnit = newVal;
                    });
                    _recalculateSilently();
                  }
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _performCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryCalcColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.translate('calculate_interest'),
                  style: AppTextStyles.timeFrameSelectedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
