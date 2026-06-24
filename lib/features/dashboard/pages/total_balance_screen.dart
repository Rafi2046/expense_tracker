import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/utils/shared_prefs_helper.dart';
import 'package:expense_tracker/features/dashboard/widgets/account_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/overall_balance_card.dart';
import 'package:expense_tracker/features/dashboard/widgets/adjust_balance_actions.dart';
import 'account_details_screen.dart';

class TotalBalanceScreen extends StatefulWidget {
  const TotalBalanceScreen({super.key});

  @override
  State<TotalBalanceScreen> createState() => _TotalBalanceScreenState();
}

class _TotalBalanceScreenState extends State<TotalBalanceScreen> {
  bool _showBalances = true;

  @override
  void initState() {
    super.initState();
    _showBalances = SharedPrefsHelper.getBool('show_balances') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final debtProvider = context.watch<DebtProvider>();

    // Calculate Cash Balance and Bank Balance dynamically
    double cashBalance = 0.0;
    double bankBalance = 0.0;

    for (var tx in txProvider.transactions) {
      if (tx.paymentMethod == 'Cash') {
        if (tx.isIncome) {
          cashBalance += tx.amount;
        } else {
          cashBalance -= tx.amount;
        }
      } else if (tx.paymentMethod == 'Bank') {
        if (tx.isIncome) {
          bankBalance += tx.amount;
        } else {
          bankBalance -= tx.amount;
        }
      }
    }

    for (var d in debtProvider.items) {
      if (d.isReceive) {
        cashBalance += d.amount;
      } else {
        cashBalance -= d.amount;
      }
    }

    final double totalBalance = cashBalance + bankBalance;

    // Standard localized formatter
    String formatAmount(double val) {
      final formatted = (val % 1 == 0)
          ? val.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )
          : val.toStringAsFixed(2).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              );
      return 'Tk. $formatted';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cash & Bank Accounts',
          style: AppTextStyles.reportAppBarTitle.copyWith(fontSize: 16.5),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFF1F1F1), height: 1.0),
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
                showBalances: _showBalances,
                onToggleBalances: () {
                  setState(() {
                    _showBalances = !_showBalances;
                    SharedPrefsHelper.setBool('show_balances', _showBalances);
                  });
                },
              ),
              const SizedBox(height: 20),

              // Section Header: All Accounts + New Account
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Accounts',
                    style: GoogleFonts.workSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => showNewAccountDialog(context),
                    icon: const Icon(
                      Icons.add,
                      size: 14,
                      color: Color(0xFF006C49),
                    ),
                    label: Text(
                      'New Account',
                      style: GoogleFonts.workSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF006C49),
                      ),
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
                      balance: _showBalances ? formatAmount(cashBalance) : 'Tk. ••••',
                      icon: Icons.payments_outlined,
                      iconBg: const Color(0xFFE6F3EE),
                      iconColor: const Color(0xFF006C49),
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
                      balance: _showBalances ? formatAmount(bankBalance) : 'Tk. ••••',
                      icon: Icons.account_balance_outlined,
                      iconBg: const Color(0xFFEBF3F9),
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
                    backgroundColor: const Color(0xFF0C4E3C),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shadowColor: const Color(0xFF0C4E3C).withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Adjust Balance',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
