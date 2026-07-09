import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/reports/pages/bank_statement_screen.dart';
import 'package:expense_tracker/features/reports/pages/cash_in_hand_statement_screen.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AccountBalanceHeaderCard extends StatelessWidget {
  final String accountType;
  final double balance;

  const AccountBalanceHeaderCard({
    super.key,
    required this.accountType,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 4),
              PrivacyMaskedText(
                amount: balance,
                style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => accountType == 'Cash'
                      ? const CashInHandStatementScreen()
                      : const BankStatementScreen(),
                ),
              );
            },
            icon: Icon(LucideIcons.fileText, size: 14, color: primaryColor),
            label: Text(
              'View Report',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor.withValues(alpha: 0.15)),
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}
