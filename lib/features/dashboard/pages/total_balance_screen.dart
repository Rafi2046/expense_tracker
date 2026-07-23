import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/model/account_model.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/providers/profile_provider.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/overall_balance_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/adjust_balance_actions.dart';
import 'account_details_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class TotalBalanceScreen extends StatefulWidget {
  const TotalBalanceScreen({super.key});

  @override
  State<TotalBalanceScreen> createState() => _TotalBalanceScreenState();
}

class _TotalBalanceScreenState extends State<TotalBalanceScreen> {
  static bool _localMasked = false;

  final Map<String, IconData> _accountIcons = {
    'Cash': LucideIcons.creditCard,
    'Bank': LucideIcons.landmark,
  };

  final Map<String, Color> _accountColors = {
    'Cash': const Color(0xFF006C49),
    'Bank': const Color(0xFF2980B9),
  };

  IconData _iconForAccount(String name) {
    return _accountIcons[name] ?? LucideIcons.wallet;
  }

  Color _colorForAccount(String name, bool isDark) {
    return _accountColors[name] ?? (isDark ? Colors.white70 : const Color(0xFF6B7280));
  }

  Color _bgForAccount(String name, bool isDark) {
    if (isDark) return Colors.white10;
    return _accountColors[name]?.withValues(alpha: 0.12) ?? const Color(0xFFF0F1F3);
  }

  String _subtitleForAccount(String name) {
    switch (name) {
      case 'Cash':
        return 'Cash in Hand';
      case 'Bank':
        return 'Electronic Transfer';
      default:
        return 'Custom Account';
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = context.watch<BalanceAnalyticsProvider>();
    final accountProvider = context.watch<AccountProvider>();

    final double totalBalance = balanceProvider.allTimeTotalBalance;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.translate('accounts'),
          style: AppTextStyles.h2.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerTheme.color, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OverallBalanceCard(
                totalBalance: totalBalance,
                isMasked: _localMasked,
                onToggleMask: () => setState(() => _localMasked = !_localMasked),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Section Header: All Accounts + New Account
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.translate('all_accounts'),
                    style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  TextButton.icon(
                    onPressed: () => showNewAccountDialog(context),
                    icon: Icon(
                      LucideIcons.plus,
                      size: 14,
                      color: theme.primaryColor,
                    ),
                    label: Text(
                      context.translate('new_account'),
                      style: AppTextStyles.label.copyWith(color: theme.primaryColor),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),

              // Accounts list
              Expanded(
                child: accountProvider.accounts.isEmpty
                    ? Center(
                        child: Text(
                          context.translate('no_accounts_yet'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        children: [
                          for (final account in accountProvider.accounts)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                              child: AccountCard(
                                title: account.name,
                                subtitle: _subtitleForAccount(account.name),
                                balance: PrivacyMaskedText(
                                  amount: balanceProvider.getBalanceForAccount(account.name),
                                  isMasked: _localMasked,
                                  style: AppTextStyles.bodyBold.copyWith(color: theme.primaryColor),
                                ),
                                icon: _iconForAccount(account.name),
                                iconBg: _bgForAccount(account.name, isDark),
                                iconColor: _colorForAccount(account.name, isDark),
                                onTap: () => _showAccountOptionsSheet(context, account),
                              ),
                            ),
                        ],
                      ),
              ),

              // Sticky Bottom Adjust Balance Button
              SizedBox(
                width: double.infinity,
                height: AppSpacing.s48,
                child: ElevatedButton(
                  onPressed: () => showAdjustBalanceBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shadowColor: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    context.translate('adjust_balance'),
                    style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountOptionsSheet(BuildContext context, AccountModel account) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBuiltIn = account.name == 'Cash' || account.name == 'Bank';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.r16),
              topRight: Radius.circular(AppSpacing.r16),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(AppSpacing.r12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                account.name,
                style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                isBuiltIn ? context.translate('system_account') : context.translate('custom_account'),
                style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.s16),
              // Edit Account
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: Icon(LucideIcons.edit, color: theme.primaryColor, size: 18),
                  label: Text(
                    context.translate('edit_account'),
                    style: AppTextStyles.body.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showEditAccountDialog(context, account);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              // View Details
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: Icon(LucideIcons.eye, color: theme.primaryColor, size: 18),
                  label: Text(
                    context.translate('view_details'),
                    style: AppTextStyles.body.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailsScreen(
                          accountType: account.name,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isBuiltIn) ...[
                const SizedBox(height: AppSpacing.s8),
                // Delete
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: Icon(LucideIcons.trash2, color: Colors.red.shade400, size: 18),
                    label: Text(
                      context.translate('delete_account'),
                      style: AppTextStyles.body.copyWith(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteAccount(context, account.name);
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    context.translate('cancel'),
                    style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditAccountDialog(BuildContext context, AccountModel account) async {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(text: account.initialBalance.toStringAsFixed(2));
    String selectedType = account.type;

    final isBuiltIn = account.name == 'Cash' || account.name == 'Bank';

    try {
      await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          context.translate('edit_account'),
          style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account Name
              TextField(
                controller: nameController,
                enabled: !isBuiltIn,
                decoration: InputDecoration(
                  labelText: context.translate('account_name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              // Initial Balance
              TextField(
                controller: balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: context.translate('initial_balance'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              // Account Type dropdown
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: context.translate('account_type'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.r12),
                  ),
                ),
                items: {selectedType, 'Cash', 'Bank', 'Custom', 'Other'}.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: isBuiltIn
                    ? null
                    : (val) {
                        if (val != null) selectedType = val;
                      },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.translate('cancel'), style: AppTextStyles.body.copyWith(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newBalance = double.tryParse(balanceController.text.trim()) ?? 0.0;

              if (newName.isEmpty) return;

              final acctProv = context.read<AccountProvider>();
              final activeProfileId = context.read<ProfileProvider>().currentProfile.id;
              final navigator = Navigator.of(ctx);

              await acctProv.updateAccount(
                id: account.id,
                name: newName,
                type: selectedType,
                initialBalance: newBalance,
                profileId: activeProfileId,
              );

              if (context.mounted) {
                context.read<TransactionProvider>().reloadFromDatabase();
              }

              navigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(context.translate('save'), style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    } finally {
      nameController.dispose();
      balanceController.dispose();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext dialogContext, String accountName) async {
    final acctProv = context.read<AccountProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(dialogContext);
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.red.shade400, size: AppSpacing.s24),
            const SizedBox(width: AppSpacing.s8),
            Text(context.translate('delete_account'), style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
        content: Text(
          context.translate('delete_account_confirmation', namedArgs: {'account_name': accountName}),
          style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.translate('cancel'), style: AppTextStyles.body.copyWith(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: Text(context.translate('delete'), style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await acctProv.deleteAccountByName(accountName);
      if (!mounted) return;
      context.read<TransactionProvider>().reloadFromDatabase();
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.translate('account_deleted_message', namedArgs: {'account_name': accountName})),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
