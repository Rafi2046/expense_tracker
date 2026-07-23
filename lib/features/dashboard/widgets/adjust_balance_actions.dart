import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'transfer_dialog.dart';
import 'new_account_dialog.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/features/dashboard/widgets/adjust_balance_header.dart';
import 'package:expense_tracker/features/dashboard/widgets/balance_action_list.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



/// Central helper function to show the overall Adjust Balance Bottom Sheet.
void showAdjustBalanceBottomSheet(BuildContext context, {String? initialAccount}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.r24),
            topRight: Radius.circular(AppSpacing.r24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, MediaQuery.of(ctx).padding.bottom + AppSpacing.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdjustBalanceHeader(
              title: context.translate('adjust_balance'),
              onClose: () => Navigator.pop(ctx),
            ),
            BalanceActionList(
              onAddReduceMoney: () {
                Navigator.pop(ctx);
                showAddReduceChoiceSheet(context);
              },
              onTransferBalance: () {
                Navigator.pop(ctx);
                showTransferDialog(context, initialFromAccount: initialAccount);
              },
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
        ),
      );
    },
  );
}

/// Central helper to choose between Income and Expense for Add/Reduce Money.
void showAddReduceChoiceSheet(BuildContext context) {
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
            topLeft: Radius.circular(AppSpacing.r24),
            topRight: Radius.circular(AppSpacing.r24),
          ),
        ),
        padding: EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, MediaQuery.of(ctx).padding.bottom + AppSpacing.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              context.translate('choose_transaction_type'),
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(height: AppSpacing.s48,
                    child: TextButton.icon(
                      icon: Icon(
                        LucideIcons.arrowDown,
                        size: 16,
                        color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                      ),
                      label: Text(
                        context.translate('add_income'),
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold,
                          color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? theme.primaryColor.withValues(alpha: 0.15)
                            : const Color(0xFFE6F3EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        AddTransactionSheet.show(
                          context: context,
                          isIncome: true,
                          enableBalanceWarning: true,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: SizedBox(height: AppSpacing.s48,
                    child: TextButton.icon(
                      icon: Icon(
                        LucideIcons.arrowUp,
                        size: 16,
                        color: isDark ? AppColors.activeRed : const Color(0xFFD9383A),
                      ),
                      label: Text(
                        context.translate('add_expense'),
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.activeRed : const Color(0xFFD9383A),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.activeRed.withValues(alpha: 0.15)
                            : const Color(0xFFFDECEC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.r12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        AddTransactionSheet.show(
                          context: context,
                          isIncome: false,
                          enableBalanceWarning: true,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
        ),
      );
    },
  );
}

/// Launches the stateful Transfer Balance Dialog.
void showTransferDialog(BuildContext context, {String? initialFromAccount}) {
  showDialog(
    context: context,
    builder: (ctx) => TransferDialog(initialFromAccount: initialFromAccount),
  );
}

/// Launches the stateful New Account Dialog.
void showNewAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => const NewAccountDialog(),
  );
}
