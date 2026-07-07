import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PartyStatementCardView extends StatelessWidget {
  final bool isMasked;

  const PartyStatementCardView({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;
    final totals = reportsProvider.partyStatementTotals;

    if (partyName == null || transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final double netBalance = totals['netBalance'] ?? 0.0;

    double moneyIn = 0.0;
    double moneyOut = 0.0;
    for (var entry in transactions) {
      if (entry.isOpeningBalance) continue;
      if (entry.isInflow) {
        moneyIn += entry.amount;
      } else {
        moneyOut += entry.amount;
      }
    }

    final chronological = transactions.reversed.toList();
    double balance = 0.0;
    final Map<String, double> runningBalances = {};
    for (var entry in chronological) {
      if (entry.isInflow) {
        balance += entry.amount;
      } else {
        balance -= entry.amount;
      }
      runningBalances[entry.id] = balance;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isReceivable = netBalance >= 0;
    final cardBgGradient = isReceivable
        ? (isDark
            ? LinearGradient(
                colors: [AppColors.activeGreen.withValues(alpha: 0.15), AppColors.activeGreen.withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF4FBF9), Color(0xFFE8F7F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
        : (isDark
            ? LinearGradient(
                colors: [AppColors.activeRed.withValues(alpha: 0.15), AppColors.activeRed.withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFF7F7), Color(0xFFFDECEC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));
    final cardBorderColor = isReceivable
        ? (isDark ? AppColors.activeGreen.withValues(alpha: 0.3) : const Color(0xFFD3EFE8))
        : (isDark ? AppColors.activeRed.withValues(alpha: 0.3) : const Color(0xFFFBD7D7));
    final cardAccentColor = isReceivable ? AppColors.activeGreen : AppColors.activeRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Total Receivables/Payables Card ──
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: cardBgGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    color: cardAccentColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isReceivable ? 'Total Receivables' : 'Total Payables',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: isReceivable
                                  ? (isDark ? AppColors.activeGreen : const Color(0xFF146C48)).withValues(alpha: 0.7)
                                  : (isDark ? AppColors.activeRed : const Color(0xFFDC3545)).withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          PrivacyMaskedText(
                            amount: netBalance.abs(),
                            isMasked: isMasked,
                            style: AppTextStyles.reportLargeValue.copyWith(
                              color: cardAccentColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Money In & Money Out Cards ──
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.activeGreen.withValues(alpha: 0.08) : const Color(0xFFF2FBF7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.activeGreen.withValues(alpha: 0.2) : const Color(0xFFD8F3E5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.activeGreen.withValues(alpha: 0.15) : const Color(0xFFE1F7EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_downward_rounded,
                        color: AppColors.activeGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Money In',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: (isDark ? AppColors.activeGreen : const Color(0xFF146C48)).withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          PrivacyMaskedText(
                            amount: moneyIn,
                            isMasked: isMasked,
                            style: AppTextStyles.reportTransactionTitle.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.activeRed.withValues(alpha: 0.08) : const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.activeRed.withValues(alpha: 0.2) : const Color(0xFFFAD1D1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.activeRed.withValues(alpha: 0.15) : const Color(0xFFFFEAEA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_upward_rounded,
                        color: AppColors.activeRed,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Money Out',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: (isDark ? AppColors.activeRed : const Color(0xFFDC3545)).withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          PrivacyMaskedText(
                            amount: moneyOut,
                            isMasked: isMasked,
                            style: AppTextStyles.reportTransactionTitle.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Section Header ──
        Text(
          'Transactions',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),

        // ── Transaction Tiles ──
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = transactions[index];
            final entryBal = runningBalances[entry.id] ?? 0.0;
            final isEntryBalPositive = entryBal >= 0;

            final isInflow = entry.isInflow;
            final typeColor = isInflow ? AppColors.activeGreen : AppColors.activeRed;

            return _PremiumTransactionTile(
              description: entry.description,
              dateTime: entry.dateTime,
              amount: entry.amount,
              isInflow: isInflow,
              isOpeningBalance: entry.isOpeningBalance,
              entryBalance: entryBal,
              isEntryBalPositive: isEntryBalPositive,
              typeColor: typeColor,
              theme: theme,
              isDark: isDark,
              isMasked: isMasked,
            );
          },
        ),
      ],
    );
  }
}

class _PremiumTransactionTile extends StatelessWidget {
  final String description;
  final DateTime dateTime;
  final double amount;
  final bool isInflow;
  final bool isOpeningBalance;
  final double entryBalance;
  final bool isEntryBalPositive;
  final Color typeColor;
  final ThemeData theme;
  final bool isDark;
  final bool isMasked;

  const _PremiumTransactionTile({
    required this.description,
    required this.dateTime,
    required this.amount,
    required this.isInflow,
    required this.isOpeningBalance,
    required this.entryBalance,
    required this.isEntryBalPositive,
    required this.typeColor,
    required this.theme,
    required this.isDark,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final IconData leadingIcon;
    final Color iconBgColor;
    final Color iconFgColor;

    if (isOpeningBalance) {
      leadingIcon = Symbols.account_balance_wallet_rounded;
      iconBgColor = isDark
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.primary.withValues(alpha: 0.08);
      iconFgColor = theme.colorScheme.primary;
    } else if (isInflow) {
      leadingIcon = Symbols.south_west_rounded;
      iconBgColor = isDark
          ? AppColors.activeGreen.withValues(alpha: 0.14)
          : const Color(0xFFE6F9F0);
      iconFgColor = AppColors.activeGreen;
    } else {
      leadingIcon = Symbols.north_east_rounded;
      iconBgColor = isDark
          ? AppColors.activeRed.withValues(alpha: 0.14)
          : const Color(0xFFFDE9EB);
      iconFgColor = AppColors.activeRed;
    }

    final balPillBg = isEntryBalPositive
        ? (isDark ? AppColors.activeGreen.withValues(alpha: 0.10) : const Color(0xFFEBF9F3))
        : (isDark ? AppColors.activeRed.withValues(alpha: 0.10) : const Color(0xFFFCECEE));
    final balPillBorder = isEntryBalPositive
        ? (isDark ? AppColors.activeGreen.withValues(alpha: 0.18) : const Color(0xFFCFF0DF))
        : (isDark ? AppColors.activeRed.withValues(alpha: 0.18) : const Color(0xFFF8D4D8));
    final balPillTextColor = isEntryBalPositive ? AppColors.activeGreen : AppColors.activeRed;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 3,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              leadingIcon,
              color: iconFgColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat('dd MMM yyyy • h:mm a').format(dateTime),
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isInflow ? '+ ' : '− ',
                    style: GoogleFonts.workSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  PrivacyMaskedText(
                    amount: amount,
                    isMasked: isMasked,
                    style: GoogleFonts.workSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: balPillBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: balPillBorder,
                    width: 0.8,
                  ),
                ),
                child: PrivacyMaskedText(
                  amount: entryBalance.abs(),
                  isMasked: isMasked,
                  style: GoogleFonts.workSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: balPillTextColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
