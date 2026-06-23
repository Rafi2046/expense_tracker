import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/calculators/utils/calculator_utils.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_info_card.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_card.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_item.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_text_field.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_type_selector.dart';
import 'package:flutter/material.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({super.key});

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _rateController;

  bool _isInclusive = false;

  double _taxAmount = 0;
  double _baseAmount = 0;
  double _totalAmount = 0;
  double _taxRate = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '');
    _rateController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _performCalculation() {
    final String amountText = _amountController.text.trim();
    final String rateText = _rateController.text.trim();

    if (amountText.isEmpty || rateText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_fill_fields', listen: false)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double amount = double.tryParse(amountText) ?? 0;
    final double rate = double.tryParse(rateText) ?? 0;

    if (amount <= 0 || rate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_enter_valid', listen: false)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final results = CalculatorUtils.calculateTax(amount: amount, rate: rate, isInclusive: _isInclusive);

    setState(() {
      _taxAmount = results['tax'] ?? 0;
      _baseAmount = results['base'] ?? 0;
      _totalAmount = results['total'] ?? 0;
      _taxRate = rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final symbol = context.currencySymbol;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('tax_calculator'),
          style: AppTextStyles.calculatorTitle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F1F1), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalculatorTypeSelector(
                title1: context.translate('tax_exclusive'),
                title2: context.translate('tax_inclusive'),
                isSelected1: !_isInclusive,
                onTap1: () {
                  setState(() {
                    _isInclusive = false;
                  });
                  _performCalculation();
                },
                onTap2: () {
                  setState(() {
                    _isInclusive = true;
                  });
                  _performCalculation();
                },
              ),
              const SizedBox(height: 20),

              CalculatorResultCard(
                label: context.translate('tax_amount'),
                value: context.formatAmount(_taxAmount),
                gradientColors: const [Color(0xFFE06C45), Color(0xFFF08955)],
                shadowColor: const Color(0xFFE06C45),
                subItems: [
                  CalculatorResultItem(title: context.translate('base_amount'), value: context.formatAmount(_baseAmount)),
                  CalculatorResultItem(title: context.translate('tax_rate'), value: '${_taxRate.toStringAsFixed(1)}%'),
                ],
                bottomItem: CalculatorResultItem(title: context.translate('total_amount'), value: context.formatAmount(_totalAmount), isCenter: true),
              ),
              const SizedBox(height: 24),

              CalculatorInfoCard(
                title: context.translate('tax_calculation_info'),
                themeColor: const Color(0xFFE06C45),
                items: [
                  CalculatorInfoItem(
                    label: context.translate('tax_exclusive'),
                    description: context.translate('tax_exclusive_desc'),
                  ),
                  CalculatorInfoItem(
                    label: context.translate('tax_inclusive'),
                    description: context.translate('tax_inclusive_desc'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CalculatorTextField(
                label: '${context.translate('amount_label')} ($symbol)',
                hintText: context.translate('amount_label'),
                controller: _amountController,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE06C45))),
                ),
              ),
              const SizedBox(height: 16),

              CalculatorTextField(
                label: context.translate('tax_rate'),
                hintText: context.translate('tax_rate'),
                controller: _rateController,
                suffix: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 16),
                  child: Text('%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE06C45))),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _performCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE06C45),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.translate('calculate_tax'),
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
