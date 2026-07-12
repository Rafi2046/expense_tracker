import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'debt_sheet_header.dart';
import 'debt_form_fields.dart';
import 'debt_save_button.dart';

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
      fontSize: AppFontSizes.size14,
      color: theme.colorScheme.onSurface,
    );
    final labelStyle = GoogleFonts.inter(
      fontSize: AppFontSizes.size14,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
    );
    final enabledBorderSide = BorderSide(
      color:
          theme.dividerTheme.color ??
          (isDark ? Colors.white12 : Colors.grey.shade300),
    );
    final focusedBorderSide = BorderSide(color: widget.themeColor, width: 1.5);

    final double viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    final double maxHeight = (MediaQuery.of(context).size.height - viewInsets) * 0.85;

    final saveLabel = widget.item == null ? 'Save Entry' : 'Update Entry';

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.br20),
            topRight: Radius.circular(AppSpacing.br20),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DebtSheetHeader(
                  titleText: titleText,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
                DebtFormFields(
                  nameController: _nameController,
                  detailController: _detailController,
                  amountController: _amountController,
                  payeeLabel: widget.payeeLabel,
                  inputStyle: inputStyle,
                  labelStyle: labelStyle,
                  enabledBorderSide: enabledBorderSide,
                  focusedBorderSide: focusedBorderSide,
                  nameValidator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a name'
                      : null,
                  detailValidator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter details'
                      : null,
                  amountValidator: (val) {
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
                DebtSaveButton(
                  themeColor: widget.themeColor,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final name = _nameController.text.trim();
                      final details = _detailController.text.trim();
                      final amount = double.parse(
                        _amountController.text.trim(),
                      );

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
                      Navigator.of(context).pop();
                    }
                  },
                  label: saveLabel,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
