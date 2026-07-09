import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetBudgetDialog extends StatefulWidget {
  final double currentAmount;

  const SetBudgetDialog({super.key, this.currentAmount = 0});

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentAmount > 0 ? widget.currentAmount.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.br12),
      ),
      title: Text(
        widget.currentAmount > 0 ? 'Edit Monthly Budget' : 'Set Monthly Budget',
        style: AppTextStyles.dialogTitle.copyWith(color: onSurface),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: onSurface),
          decoration: InputDecoration(
            labelText: 'Budget Amount (${context.currencySymbol})',
            hintText: 'Enter amount',
            labelStyle: AppTextStyles.textFieldLabel.copyWith(color: isDark ? Colors.grey.shade400 : null),
            hintStyle: AppTextStyles.textFieldHint.copyWith(color: isDark ? Colors.grey.shade500 : null),
            prefixText: '${context.currencySymbol} ',
            prefixStyle: AppTextStyles.calculatorInputText.copyWith(color: onSurface),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br8),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br8),
              borderSide: BorderSide(color: (isDark ? Colors.grey.shade600 : AppColors.borderColor).withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.br8),
              borderSide: BorderSide(color: isDark ? const Color(0xFF8E75C8) : AppColors.buttonColor, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }
            final parsed = double.tryParse(value.trim());
            if (parsed == null || parsed <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTextStyles.dialogCloseButton.copyWith(color: isDark ? Colors.grey.shade400 : AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_controller.text.trim());
              Navigator.of(context).pop(amount);
            }
          },
          child: Text('Save', style: AppTextStyles.dialogCloseButton),
        ),
      ],
    );
  }
}
