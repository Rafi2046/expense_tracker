import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/calculators/utils/calculator_utils.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_breakdown_card.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_card.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_result_item.dart';
import 'package:expense_tracker/features/calculators/widgets/calculator_text_field.dart';
import 'package:flutter/material.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _rateController;
  late final TextEditingController _tenureController;

  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;
  double _principalAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '');
    _rateController = TextEditingController(text: '');
    _tenureController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _performCalculation() {
    final String amountText = _amountController.text.trim();
    final String rateText = _rateController.text.trim();
    final String tenureText = _tenureController.text.trim();

    if (amountText.isEmpty || rateText.isEmpty || tenureText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_fill_fields')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double amount = double.tryParse(amountText) ?? 0;
    final double rate = double.tryParse(rateText) ?? 0;
    final double years = double.tryParse(tenureText) ?? 0;

    if (amount <= 0 || rate < 0 || years <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('please_enter_valid')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final results = CalculatorUtils.calculateEmi(amount: amount, rate: rate, years: years);

    setState(() {
      _emi = results['emi'] ?? 0;
      _totalInterest = results['interest'] ?? 0;
      _totalPayment = results['payment'] ?? 0;
      _principalAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final interestRatio = _totalPayment > 0 ? (_totalInterest / _totalPayment) : 0.0;
    final principalRatio = _totalPayment > 0 ? (_principalAmount / _totalPayment) : 0.0;
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
          context.translate('emi_calculator'),
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
              CalculatorResultCard(
                label: context.translate('monthly_emi'),
                value: context.formatAmount(_emi),
                gradientColors: const [Color(0xFF006C49), Color(0xFF00895C)],
                shadowColor: const Color(0xFF006C49),
                subItems: [
                  CalculatorResultItem(title: context.translate('total_principal'), value: context.formatAmount(_principalAmount)),
                  CalculatorResultItem(title: context.translate('total_interest'), value: context.formatAmount(_totalInterest)),
                ],
                bottomItem: CalculatorResultItem(title: context.translate('total_payable'), value: context.formatAmount(_totalPayment), isCenter: true),
              ),
              const SizedBox(height: 24),

              CalculatorBreakdownCard(
                title: context.translate('payment_breakdown'),
                label1: context.translate('principal'),
                color1: const Color(0xFF006C49),
                ratio1: principalRatio,
                label2: context.translate('interest'),
                color2: AppColors.expensePink,
                ratio2: interestRatio,
              ),
              const SizedBox(height: 24),

              CalculatorTextField(
                label: '${context.translate('loan_amount')} ($symbol)',
                hintText: context.translate('loan_amount'),
                controller: _amountController,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(symbol, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006C49))),
                ),
              ),
              const SizedBox(height: 16),

              CalculatorTextField(
                label: context.translate('loan_interest_rate'),
                hintText: context.translate('interest'),
                controller: _rateController,
                suffix: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 16),
                  child: Text('%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006C49))),
                ),
              ),
              const SizedBox(height: 16),

              CalculatorTextField(
                label: context.translate('loan_tenure'),
                hintText: context.translate('years_label'),
                controller: _tenureController,
                suffix: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: Text(context.translate('years_label'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006C49))),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _performCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006C49),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.translate('calculate_emi'),
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
