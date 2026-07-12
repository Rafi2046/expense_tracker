import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/core/providers/transaction_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/features/dashboard/pages/transaction_details_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class AccountTransactionRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final String accountType;

  const AccountTransactionRow({
    super.key,
    required this.item,
    this.accountType = 'Cash',
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = item['isIncome'];
    final double amount = item['amount'];
    final double runningBal = item['runningBalance'];
    final String title = item['title'];
    final String category = item['category'];
    final DateTime dateTime = item['dateTime'];
    final rawItem = item['item'];
    final isPartyDebt = rawItem is DebtItem && (rawItem.phone != null || rawItem.email != null || rawItem.address != null);
    final displayCategory = isPartyDebt ? 'Party' : category;

    final amountColor = isIncome
        ? const Color(0xFF2EBD85)
        : const Color(0xFFDC3545);
    final amountPrefix = isIncome ? '+ ' : '- ';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          final rawItem = item['item'];
          if (rawItem is TransactionItem) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailsScreen(transaction: rawItem),
              ),
            );
          } else if (rawItem is DebtItem) {
            final debtThemeColor = rawItem.isReceive
                ? theme.primaryColor
                : AppColors.activeRed;
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (sheetContext) => Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + MediaQuery.of(sheetContext).padding.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerTheme.color ?? Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.edit, color: theme.colorScheme.onSurface),
                      title: Text('Edit', style: TextStyle(color: theme.colorScheme.onSurface)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        AddEditDebtSheet.show(
                          context: context,
                          item: rawItem,
                          payeeLabel: 'Client/Friend Name',
                          themeColor: debtThemeColor,
                          isReceive: rawItem.isReceive,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.checkCircle, color: debtThemeColor),
                      title: Text('Settle', style: TextStyle(color: debtThemeColor)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        final txProvider = context.read<TransactionProvider>();
                        final debtProvider = context.read<DebtProvider>();
                        final settlementTx = TransactionItem(
                          id: '',
                          amount: rawItem.amount,
                          category: 'Settlement',
                          note: 'Debt settlement - ${rawItem.name}',
                          isIncome: rawItem.isReceive,
                          dateTime: DateTime.now(),
                          paymentMethod: accountType,
                          partyName: rawItem.name,
                        );
                        txProvider.addTransaction(settlementTx);
                        debtProvider.settleDebtItem(rawItem.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${rawItem.name}\'s debt settled'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(LucideIcons.trash2, color: Colors.red.shade400),
                      title: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
                            title: Text('Delete Debt', style: TextStyle(color: theme.colorScheme.onSurface)),
                            content: Text(
                              'Are you sure you want to delete this debt?',
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<DebtProvider>().deleteDebtItem(rawItem.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${rawItem.name}\'s debt deleted'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Header Type badge & Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isIncome ? 'Income #1' : 'Expense #1',
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size10,
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? const Color(0xFF2EBD85)
                          : const Color(0xFFDC3545),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amountPrefix,
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size14,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                      PrivacyMaskedText(
                        amount: amount,
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size14,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: Title & Running Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.workSans(
                        fontSize: AppFontSizes.size14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFE6F3EE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Bal: ',
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                          ),
                        ),
                        PrivacyMaskedText(
                          amount: runningBal,
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3: Date/Time & Category Icon/Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy • h:mm a').format(dateTime),
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  isPartyDebt
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.users, size: 12, color: const Color(0xFF7C3AED)),
                            const SizedBox(width: 4),
                            Text(
                              displayCategory,
                              style: GoogleFonts.workSans(
                                fontSize: AppFontSizes.size10,
                                color: const Color(0xFF7C3AED),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          displayCategory,
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
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
