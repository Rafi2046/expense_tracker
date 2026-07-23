import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TransferDialog extends StatefulWidget {
  final String? initialFromAccount;

  const TransferDialog({super.key, this.initialFromAccount});

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _fromAccount;
  late String _toAccount;

  @override
  void initState() {
    super.initState();
    _fromAccount = widget.initialFromAccount ?? 'Cash';
    _toAccount = 'Bank';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accountProvider = context.watch<AccountProvider>();
    final accounts = accountProvider.accounts;

    final fromAccounts = accounts.where((a) => a.name != _toAccount).toList();
    final toAccounts = accounts.where((a) => a.name != _fromAccount).toList();

    if (fromAccounts.isEmpty || toAccounts.isEmpty) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r16)),
        title: Text(context.translate('transfer_btn'), style: AppTextStyles.h3),
        content: Text(
          context.translate('need_two_accounts'),
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.translate('ok'), style: AppTextStyles.body.copyWith(color: theme.primaryColor)),
          ),
        ],
      );
    }

    // Ensure selected accounts are still valid
    if (!accounts.any((a) => a.name == _fromAccount)) {
      _fromAccount = fromAccounts.first.name;
    }
    if (!accounts.any((a) => a.name == _toAccount)) {
      _toAccount = toAccounts.first.name;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r16)),
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.r8),
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.arrowLeftRight, color: theme.primaryColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            context.translate('transfer_balance'),
            style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // From → To
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('from_$_fromAccount'),
                    initialValue: _fromAccount,
                    decoration: InputDecoration(
                      labelText: context.translate('from_label'),
                      labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p8),
                    ),
                    items: accounts
                        .where((a) => a.name != _toAccount)
                        .map((a) => DropdownMenuItem(
                              value: a.name,
                              child: Text(a.name, style: AppTextStyles.body),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _fromAccount = val;
                          if (_toAccount == val) {
                            _toAccount = accounts.firstWhere((a) => a.name != val).name;
                          }
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8),
                  child: Icon(LucideIcons.arrowRight, color: theme.colorScheme.onSurfaceVariant, size: 18),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('to_$_toAccount'),
                    initialValue: _toAccount,
                    decoration: InputDecoration(
                      labelText: context.translate('to_label'),
                      labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                        borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p8),
                    ),
                    items: accounts
                        .where((a) => a.name != _fromAccount)
                        .map((a) => DropdownMenuItem(
                              value: a.name,
                              child: Text(a.name, style: AppTextStyles.body),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _toAccount = val;
                          if (_fromAccount == val) {
                            _fromAccount = accounts.firstWhere((a) => a.name != val).name;
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: context.translate('transfer_amount'),
                labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                prefixText: '${context.currencySymbol} ',
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.r12),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p12),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return context.translate('enter_amount');
                if (double.tryParse(val) == null || double.parse(val) <= 0) return context.translate('enter_valid_amount');
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.translate('cancel'), style: AppTextStyles.body.copyWith(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _handleTransfer,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r8)),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
          ),
          child: Text(context.translate('transfer_btn'), style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    if (_fromAccount == _toAccount) return;

    final balanceProvider = context.read<BalanceAnalyticsProvider>();
    final projected = balanceProvider.projectedBalance(
      _fromAccount,
      amount: amount,
      isIncome: false,
    );

    if (projected < 0) {
      final theme = Theme.of(context);
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.r16)),
          title: Text(context.translate('balance_will_go_negative'),
            style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            context.translate('balance_negative_warning', namedArgs: {
              'account': _fromAccount,
              'balance': context.formatAmount(projected, listen: false),
            }),
            style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.translate('cancel'), style: AppTextStyles.body.copyWith(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.activeRed),
              child: Text(context.translate('proceed'), style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
            ),
          ],
        ),
      );
      if (proceed != true || !context.mounted) return;
    }

    if (!mounted) return;
    context.read<TransactionProvider>().transferBalance(amount, _fromAccount, _toAccount);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.translate('transfer_success', namedArgs: {
            'amount': context.formatAmount(amount, listen: false),
            'from': _fromAccount,
            'to': _toAccount,
          }),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
