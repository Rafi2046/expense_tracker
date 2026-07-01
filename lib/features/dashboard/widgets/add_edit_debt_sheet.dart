import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddEditDebtSheet extends StatefulWidget {
  final DebtItem? item;
  final String payeeLabel;
  final Color themeColor;
  final bool isReceive;

  const AddEditDebtSheet({
    super.key,
    this.item,
    required this.payeeLabel,
    required this.themeColor,
    required this.isReceive,
  });

  static void show({
    required BuildContext context,
    DebtItem? item,
    required String payeeLabel,
    required Color themeColor,
    required bool isReceive,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.br20),
        ),
      ),
      builder: (context) {
        return AddEditDebtSheet(
          item: item,
          payeeLabel: payeeLabel,
          themeColor: themeColor,
          isReceive: isReceive,
        );
      },
    );
  }

  @override
  State<AddEditDebtSheet> createState() => _AddEditDebtSheetState();
}

class _AddEditDebtSheetState extends State<AddEditDebtSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _detailController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _detailController = TextEditingController(text: widget.item?.detail ?? '');
    _amountController = TextEditingController(
      text: widget.item != null ? widget.item!.amount.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleText = widget.item == null
        ? (widget.isReceive ? 'Add Owed Entry' : 'Add Owed Entry (To Give)')
        : (widget.isReceive ? 'Edit Owed Entry' : 'Edit Owed Entry (To Give)');

    final inputStyle = GoogleFonts.inter(
      fontSize: 14,
      color: theme.colorScheme.onSurface,
    );
    final labelStyle = GoogleFonts.inter(
      fontSize: 14,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
    final enabledBorderSide = BorderSide(
      color: theme.dividerTheme.color ?? (isDark ? Colors.white12 : Colors.grey.shade300),
    );
    final focusedBorderSide = BorderSide(
      color: widget.themeColor,
      width: 1.5,
    );

    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    final double systemBottomPadding = MediaQueryData.fromView(View.of(context)).padding.bottom;
    final double bottomPadding = keyboardPadding > 0
        ? keyboardPadding + 20
        : systemBottomPadding + 84;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titleText,
                  style: GoogleFonts.workSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Symbols.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: inputStyle,
              decoration: InputDecoration(
                labelText: widget.payeeLabel,
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
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailController,
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
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Please enter details'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
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
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final parsed = double.tryParse(val);
                if (parsed == null || parsed <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.br12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text.trim();
                    final details = _detailController.text.trim();
                    final amount = double.parse(_amountController.text.trim());

                    if (widget.item == null) {
                      final newItem = DebtItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        detail: details,
                        amount: amount,
                        isReceive: widget.isReceive,
                        isSettled: false,
                        createdAt: DateTime.now(),
                      );
                      context.read<DebtProvider>().addDebtItem(newItem);
                    } else {
                      final updated = widget.item!.copyWith(
                        name: name,
                        detail: details,
                        amount: amount,
                      );
                      context.read<DebtProvider>().updateDebtItem(updated);
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.item == null
                              ? 'Added entry successfully'
                              : 'Updated entry successfully',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(
                  widget.item == null ? 'Save Entry' : 'Update Entry',
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
