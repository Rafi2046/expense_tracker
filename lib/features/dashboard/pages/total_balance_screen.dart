import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/balance_analytics_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/overall_balance_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/adjust_balance_actions.dart';
import 'account_details_screen.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TotalBalanceScreen extends StatefulWidget {
  const TotalBalanceScreen({super.key});

  @override
  State<TotalBalanceScreen> createState() => _TotalBalanceScreenState();
}

class _TotalBalanceScreenState extends State<TotalBalanceScreen> {
  static bool _localMasked = false;

  @override
  Widget build(BuildContext context) {
    final balanceProvider = context.watch<BalanceAnalyticsProvider>();

    final double cashBalance = balanceProvider.allTimeCashBalance;
    final double bankBalance = balanceProvider.allTimeBankBalance;
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
          'Cash & Bank Accounts',
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

              // Accounts list (Compact spacing)
              Expanded(
                child: ListView(
                  children: [
                    AccountCard(
                      title: 'Cash',
                      subtitle: 'Cash in Hand',
                      balance: PrivacyMaskedText(
                        amount: cashBalance,
                        isMasked: _localMasked,
                        style: AppTextStyles.bodyBold.copyWith(color: theme.primaryColor),
                      ),
                      icon: LucideIcons.creditCard,
                      iconBg: isDark ? Colors.white10 : const Color(0xFFE6F3EE),
                      iconColor: isDark ? theme.primaryColor : const Color(0xFF006C49),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountDetailsScreen(accountType: 'Cash'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    AccountCard(
                      title: 'Bank Account',
                      subtitle: 'Electronic Transfer',
                      balance: PrivacyMaskedText(
                        amount: bankBalance,
                        isMasked: _localMasked,
                        style: AppTextStyles.bodyBold.copyWith(color: theme.primaryColor),
                      ),
                      icon: LucideIcons.landmark,
                      iconBg: isDark ? Colors.white10 : const Color(0xFFEBF3F9),
                      iconColor: const Color(0xFF2980B9),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountDetailsScreen(accountType: 'Bank'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Adjust Balance Button (Compact)
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
}
