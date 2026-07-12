import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Transfer', style: AppTextStyles.h3),
        content: Text(
          'Need at least 2 accounts to transfer.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTextStyles.body.copyWith(color: theme.primaryColor)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.cardColor,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.arrowLeftRight, color: theme.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Transfer Balance',
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
                      labelText: 'From',
                      labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: accounts
                        .where((a) => a.name != _toAccount)
                        .map((a) => DropdownMenuItem(
                              value: a.name,
                              child: Text(a.name, style: AppTextStyles.body.copyWith(fontSize: AppFontSizes.size13)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(LucideIcons.arrowRight, color: theme.colorScheme.onSurfaceVariant, size: 18),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('to_$_toAccount'),
                    initialValue: _toAccount,
                    decoration: InputDecoration(
                      labelText: 'To',
                      labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: accounts
                        .where((a) => a.name != _fromAccount)
                        .map((a) => DropdownMenuItem(
                              value: a.name,
                              child: Text(a.name, style: AppTextStyles.body.copyWith(fontSize: AppFontSizes.size13)),
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Transfer Amount',
                labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                prefixText: '${context.currencySymbol} ',
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter amount';
                if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTextStyles.body.copyWith(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _handleTransfer,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text('Transfer', style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: AppFontSizes.size13)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Balance Will Go Negative',
            style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            'This will bring your $_fromAccount balance to '
            '${context.formatAmount(projected, listen: false)}.\n\n'
            'Are you sure you want to proceed?',
            style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: AppTextStyles.body.copyWith(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.activeRed),
              child: Text('Proceed', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
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
          'Successfully transferred ${context.formatAmount(amount, listen: false)} from $_fromAccount to $_toAccount',
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
