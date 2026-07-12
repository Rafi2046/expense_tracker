import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NewAccountDialog extends StatefulWidget {
  const NewAccountDialog({super.key});

  @override
  State<NewAccountDialog> createState() => _NewAccountDialogState();
}

class _NewAccountDialogState extends State<NewAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
            child: Icon(LucideIcons.wallet, color: theme.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Create Account',
            style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g. Bkash, Nagad, DBBL',
                hintStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: Icon(LucideIcons.landmark, size: 18, color: theme.colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Enter account name'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Initial Balance',
                hintText: '0.00',
                labelStyle: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                prefixText: '${context.currencySymbol} ',
                prefixIcon: Icon(LucideIcons.dollarSign, size: 18, color: theme.colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter initial balance';
                if (double.tryParse(val) == null) return 'Enter a valid number';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
        ),
        _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: _handleCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Create',
                  style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: AppFontSizes.size13),
                ),
              ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final balance = double.parse(_balanceController.text.isNotEmpty
          ? _balanceController.text
          : '0');

      await context.read<AccountProvider>().createAccount(
            name: name,
            type: 'Custom',
            initialBalance: balance,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$name" account created successfully!'),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create account: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
