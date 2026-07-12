import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/providers/account_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/overall_balance_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/adjust_balance_actions.dart';
import 'account_details_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
          'Accounts',
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OverallBalanceCard(
                totalBalance: totalBalance,
                isMasked: _localMasked,
                onToggleMask: () => setState(() => _localMasked = !_localMasked),
              ),
              const SizedBox(height: 20),

              // Section Header: All Accounts + New Account
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Accounts',
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
                      'New Account',
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
              const SizedBox(height: 12),

              // Accounts list
              Expanded(
                child: accountProvider.accounts.isEmpty
                    ? Center(
                        child: Text(
                          'No accounts yet. Tap "New Account" to create one.',
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
                              padding: const EdgeInsets.only(bottom: 10),
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
                                onTap: account.name == 'Cash' || account.name == 'Bank'
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AccountDetailsScreen(
                                              accountType: account.name,
                                            ),
                                          ),
                                        );
                                      }
                                    : () => _showAccountOptionsSheet(context, account.name),
                              ),
                            ),
                        ],
                      ),
              ),

              // Sticky Bottom Adjust Balance Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => showAdjustBalanceBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shadowColor: theme.primaryColor.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Adjust Balance',
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

  void _showAccountOptionsSheet(BuildContext context, String accountName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).padding.bottom + 20,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                accountName,
                style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Custom Account',
                style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              // View Details
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: Icon(LucideIcons.eye, color: theme.primaryColor, size: 18),
                  label: Text(
                    'View Details',
                    style: AppTextStyles.body.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailsScreen(
                          accountType: accountName,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Delete
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: Icon(LucideIcons.trash2, color: Colors.red.shade400, size: 18),
                  label: Text(
                    'Delete Account',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmDeleteAccount(context, accountName);
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
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

  Future<void> _confirmDeleteAccount(BuildContext dialogContext, String accountName) async {
    final acctProv = context.read<AccountProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(dialogContext);
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.red.shade400, size: 22),
            const SizedBox(width: 8),
            Text('Delete Account', style: AppTextStyles.h3.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
        content: Text(
          'Delete "$accountName" and all its transactions?\n\n'
          'This will also remove all income/expense entries linked to this account.',
          style: AppTextStyles.body.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.body.copyWith(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await acctProv.deleteAccountByName(accountName);
      if (mounted) {
        context.read<TransactionProvider>().reloadFromDatabase();
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('"$accountName" account deleted'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
