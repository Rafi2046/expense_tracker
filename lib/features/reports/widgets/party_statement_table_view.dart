import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PartyStatementTableView extends StatelessWidget {
  final bool isMasked;

  const PartyStatementTableView({super.key, this.isMasked = false});

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
    final double receiveTotal = totals['receiveTotal'] ?? 0.0;
    final double giveTotal = totals['giveTotal'] ?? 0.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isReceivable = netBalance >= 0;
    final cardBgGradient = isReceivable
        ? (isDark
              ? LinearGradient(
                  colors: [
                    AppColors.activeGreen.withValues(alpha: 0.15),
                    AppColors.activeGreen.withValues(alpha: 0.03),
                  ],
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
                  colors: [
                    AppColors.activeRed.withValues(alpha: 0.15),
                    AppColors.activeRed.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFF7F7), Color(0xFFFDECEC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ));
    final cardBorderColor = isReceivable
        ? (isDark
              ? AppColors.activeGreen.withValues(alpha: 0.3)
              : const Color(0xFFD3EFE8))
        : (isDark
              ? AppColors.activeRed.withValues(alpha: 0.3)
              : const Color(0xFFFBD7D7));
    final cardAccentColor = isReceivable
        ? AppColors.activeGreen
        : AppColors.activeRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Net Balance Card
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
                  Container(width: 5, color: cardAccentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Net Balance',
                            style: AppTextStyles.reportStatLabel.copyWith(
                              color: isReceivable
                                  ? (isDark
                                            ? AppColors.activeGreen
                                            : const Color(0xFF146C48))
                                        .withValues(alpha: 0.7)
                                  : (isDark
                                            ? AppColors.activeRed
                                            : const Color(0xFFDC3545))
                                        .withValues(alpha: 0.7),
                              fontSize: AppFontSizes.size12,
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
                              fontSize: AppFontSizes.size24,
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
        const SizedBox(height: 24),

        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                    style: AppTextStyles.reportStatLabel.copyWith(
                      color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transactions.length} entries',
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        fontSize: AppFontSizes.size11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Debit',
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: AppColors.activeGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PrivacyMaskedText(
                      amount: receiveTotal,
                      isMasked: isMasked,
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: AppColors.activeGreen,
                        fontSize: AppFontSizes.size11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Credit',
                      style: AppTextStyles.reportStatLabel.copyWith(
                        color: AppColors.activeRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PrivacyMaskedText(
                      amount: giveTotal,
                      isMasked: isMasked,
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: AppColors.activeRed,
                        fontSize: AppFontSizes.size11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: theme.dividerColor, height: 1),
        const SizedBox(height: 12),

        // Table Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = transactions[index];

            return InkWell(
              onTap: () {
                if (entry.id.startsWith('tx_')) {
                  final originalId = entry.id.substring(3);
                  final txP = context.read<TransactionProvider>();
                  final tx = txP.transactions
                      .where((t) => t.id == originalId)
                      .firstOrNull;
                  if (tx == null) return;
                  AddTransactionSheet.show(
                    context: context,
                    isIncome: entry.isInflow,
                    transaction: tx,
                  );
                } else if (entry.id.startsWith('debt_')) {
                  final originalId = entry.id.substring(5);
                  final debtP = context.read<DebtProvider>();
                  final debt = debtP.items
                      .where((d) => d.id == originalId)
                      .firstOrNull;
                  if (debt == null) return;
                  AddEditDebtSheet.show(
                    context: context,
                    item: debt,
                    payeeLabel: entry.isInflow ? 'Client/Friend Name' : 'Payee Name',
                    themeColor: entry.isInflow ? theme.primaryColor : AppColors.activeRed,
                    isReceive: entry.isInflow,
                  );
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.05 : 0.005,
                      ),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              entry.description,
                              style: AppTextStyles.reportTransactionTitle
                                  .copyWith(
                                    fontSize: AppFontSizes.size13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'dd MMM yyyy • h:mm a',
                              ).format(entry.dateTime),
                              style: AppTextStyles.reportTransactionSubtitle
                                  .copyWith(
                                    fontSize: AppFontSizes.size10,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        child: entry.isInflow
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.activeGreen.withValues(
                                          alpha: 0.15,
                                        )
                                      : const Color(0xFFE8F8F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.activeGreen.withValues(
                                            alpha: 0.3,
                                          )
                                        : const Color(0xFFD1F2E5),
                                  ),
                                ),
                                child: PrivacyMaskedText(
                                  amount: entry.amount,
                                  isMasked: isMasked,
                                  style: AppTextStyles.reportTransactionTitle
                                      .copyWith(
                                        fontSize: AppFontSizes.size12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.activeGreen,
                                      ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        child: !entry.isInflow
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.activeRed.withValues(
                                          alpha: 0.15,
                                        )
                                      : const Color(0xFFFDE8E8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.activeRed.withValues(
                                            alpha: 0.3,
                                          )
                                        : const Color(0xFFFAD1D1),
                                  ),
                                ),
                                child: PrivacyMaskedText(
                                  amount: entry.amount,
                                  isMasked: isMasked,
                                  style: AppTextStyles.reportTransactionTitle
                                      .copyWith(
                                        fontSize: AppFontSizes.size12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.activeRed,
                                      ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
