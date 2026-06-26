import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PartyStatementCardView extends StatelessWidget {
  const PartyStatementCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;
    final totals = reportsProvider.partyStatementTotals;
    final currencySymbol = context.currencySymbol;

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
        // Total Receivables/Payables Card
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
                          Text(
                            '$currencySymbol ${netBalance.abs().toStringAsFixed(0)}',
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

        // Money In & Money Out Cards
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
                          Text(
                            '$currencySymbol ${moneyIn.toStringAsFixed(0)}',
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
                          Text(
                            '$currencySymbol ${moneyOut.toStringAsFixed(0)}',
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
        const SizedBox(height: 24),

        // Transactions Lists
        Text(
          'Transactions Lists',
          style: AppTextStyles.reportTransactionTitle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = transactions[index];
            final entryBal = runningBalances[entry.id] ?? 0.0;
            final isEntryBalPositive = entryBal >= 0;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.005),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      entry.isInflow ? Symbols.arrow_downward_rounded : Symbols.arrow_upward_rounded,
                      color: entry.isInflow ? AppColors.activeGreen : AppColors.activeRed,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.description,
                          style: AppTextStyles.reportTransactionTitle.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy • h:mm a').format(entry.dateTime),
                              style: AppTextStyles.reportTransactionSubtitle.copyWith(
                                fontSize: 10.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isEntryBalPositive
                                    ? (isDark ? AppColors.activeGreen.withValues(alpha: 0.15) : const Color(0xFFE8F8F5))
                                    : (isDark ? AppColors.activeRed.withValues(alpha: 0.15) : const Color(0xFFFDE8E8)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Bal: $currencySymbol${entryBal.abs().toStringAsFixed(0)}',
                                style: AppTextStyles.reportStatLabel.copyWith(
                                  color: isEntryBalPositive ? AppColors.activeGreen : AppColors.activeRed,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$currencySymbol${entry.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: entry.isInflow ? AppColors.activeGreen : AppColors.activeRed,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
