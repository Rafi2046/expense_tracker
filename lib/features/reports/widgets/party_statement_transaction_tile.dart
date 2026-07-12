import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class PartyStatementTransactionTile extends StatelessWidget {
  final String entryId;
  final String description;
  final DateTime dateTime;
  final double amount;
  final bool isInflow;
  final bool isOpeningBalance;
  final bool isMasked;

  const PartyStatementTransactionTile({
    super.key,
    required this.entryId,
    required this.description,
    required this.dateTime,
    required this.amount,
    required this.isInflow,
    required this.isOpeningBalance,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = isInflow ? AppColors.activeGreen : AppColors.activeRed;

    final IconData leadingIcon;
    final Color iconBgColor;
    final Color iconFgColor;

    if (isOpeningBalance) {
      leadingIcon = LucideIcons.wallet;
      iconBgColor = isDark
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.primary.withValues(alpha: 0.08);
      iconFgColor = theme.colorScheme.primary;
    } else if (isInflow) {
      leadingIcon = LucideIcons.arrowDownLeft;
      iconBgColor = isDark
          ? AppColors.activeGreen.withValues(alpha: 0.14)
          : const Color(0xFFE6F9F0);
      iconFgColor = AppColors.activeGreen;
    } else {
      leadingIcon = LucideIcons.arrowUpRight;
      iconBgColor = isDark
          ? AppColors.activeRed.withValues(alpha: 0.14)
          : const Color(0xFFFDE9EB);
      iconFgColor = AppColors.activeRed;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (entryId.startsWith('tx_')) {
            final originalId = entryId.substring(3);
            final txProvider = context.read<TransactionProvider>();
            final tx = txProvider.transactions
                .where((t) => t.id == originalId)
                .firstOrNull;
            if (tx == null) return;
            AddTransactionSheet.show(
              context: context,
              isIncome: isInflow,
              transaction: tx,
            );
          } else if (entryId.startsWith('debt_')) {
            final originalId = entryId.substring(5);
            final debtProvider = context.read<DebtProvider>();
            final debt = debtProvider.items
                .where((d) => d.id == originalId)
                .firstOrNull;
            if (debt == null) return;
            AddEditDebtSheet.show(
              context: context,
              item: debt,
              payeeLabel: isInflow ? 'Client/Friend Name' : 'Payee Name',
              themeColor: isInflow ? theme.primaryColor : AppColors.activeRed,
              isReceive: isInflow,
            );
          }
        },
        child: Container(
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
                child: Icon(leadingIcon, color: iconFgColor, size: 20),
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
                      style: AppTextStyles.bodyBold.copyWith(
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat('dd MMM yyyy • h:mm a').format(dateTime),
                      style: AppTextStyles.caption.copyWith(
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
                        isInflow ? '+ ' : '\u2212 ',
                        style: AppTextStyles.reportTransactionTitle.copyWith(
                          color: typeColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      PrivacyMaskedText(
                        amount: amount,
                        isMasked: isMasked,
                        style: AppTextStyles.reportTransactionTitle.copyWith(
                          color: typeColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  if (isOpeningBalance)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Opening',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: AppFontSizes.size10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
