import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';

class DebtFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController detailController;
  final TextEditingController amountController;
  final String payeeLabel;
  final TextStyle inputStyle;
  final TextStyle labelStyle;
  final BorderSide enabledBorderSide;
  final BorderSide focusedBorderSide;
  final String? Function(String?) nameValidator;
  final String? Function(String?) detailValidator;
  final String? Function(String?) amountValidator;

  const DebtFormFields({
    super.key,
    required this.nameController,
    required this.detailController,
    required this.amountController,
    required this.payeeLabel,
    required this.inputStyle,
    required this.labelStyle,
    required this.enabledBorderSide,
    required this.focusedBorderSide,
    required this.nameValidator,
    required this.detailValidator,
    required this.amountValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          style: inputStyle,
          decoration: InputDecoration(
            labelText: payeeLabel,
            labelStyle: labelStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: enabledBorderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: enabledBorderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: focusedBorderSide,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: nameValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: detailController,
          style: inputStyle,
          decoration: InputDecoration(
            labelText: 'Details (e.g. Dinner Split, Rent, etc.)',
            labelStyle: labelStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: enabledBorderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: enabledBorderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: focusedBorderSide,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: detailValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: amountController,
          style: inputStyle,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: 'Amount (${context.currencySymbol})',
            labelStyle: labelStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: enabledBorderSide,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: enabledBorderSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br12),
              borderSide: focusedBorderSide,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: amountValidator,
        ),
      ],
    );
  }
}
