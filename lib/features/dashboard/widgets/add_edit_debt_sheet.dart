import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'debt_sheet_header.dart';
import 'debt_form_fields.dart';
import 'debt_save_button.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


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
          top: Radius.circular(AppSpacing.br24),
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
        ? (widget.isReceive ? context.translate('add_owed_entry') : context.translate('add_owed_entry_to_give'))
        : (widget.isReceive ? context.translate('edit_owed_entry') : context.translate('edit_owed_entry_to_give'));

    final inputStyle = AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface);
    final labelStyle = AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

    final saveLabel = widget.item == null ? context.translate('save_entry') : context.translate('update_entry');

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.br24),
            topRight: Radius.circular(AppSpacing.br24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, bottomInset + AppSpacing.p24),
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
                const SizedBox(height: AppSpacing.s16),
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
                      ? context.translate('please_enter_name')
                      : null,
                  detailValidator: (val) => val == null || val.trim().isEmpty
                      ? context.translate('please_enter_details')
                      : null,
                  amountValidator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return context.translate('please_enter_amount');
                    }
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed <= 0) {
                      return context.translate('please_enter_valid_positive_number');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s16),
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
                                ? context.translate('added_entry_success')
                                : context.translate('updated_entry_success'),
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
