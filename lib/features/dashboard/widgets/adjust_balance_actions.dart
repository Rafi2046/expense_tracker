import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'transfer_dialog.dart';
import 'new_account_dialog.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

/// Central helper function to show the overall Adjust Balance Bottom Sheet.
void showAdjustBalanceBottomSheet(BuildContext context, {String? initialAccount}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Adjust Balance',
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Add/Reduce Money
            _buildAdjustOptionTile(
              context: context,
              title: 'Add/Reduce Money',
              subtitle: 'Record income or expense to adjust a single account\'s balance',
              icon: Symbols.add,
              iconBg: isDark ? AppColors.activeRed.withValues(alpha: 0.15) : const Color(0xFFFDECEC),
              iconColor: AppColors.activeRed,
              onTap: () {
                Navigator.pop(ctx);
                showAddReduceChoiceSheet(context);
              },
            ),
            const SizedBox(height: 10),

            // Transfer Balance
            _buildAdjustOptionTile(
              context: context,
              title: 'Transfer Balance',
              subtitle: 'Move money between Cash and Bank accounts',
              icon: Symbols.swap_horiz_rounded,
              iconBg: isDark ? const Color(0xFF2980B9).withValues(alpha: 0.15) : const Color(0xFFEBF3F9),
              iconColor: const Color(0xFF2980B9),
              onTap: () {
                Navigator.pop(ctx);
                showTransferDialog(context, initialFromAccount: initialAccount);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Widget _buildAdjustOptionTile({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required Color iconBg,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.white10 : const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1), width: 1.2),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Transaction Type',
              style: GoogleFonts.workSans(
                fontSize: AppFontSizes.size16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextButton.icon(
                      icon: Icon(
                        Symbols.arrow_downward,
                        size: 16,
                        color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                      ),
                      label: Text(
                        'Add Income',
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? theme.primaryColor : const Color(0xFF006C49),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? theme.primaryColor.withValues(alpha: 0.15)
                            : const Color(0xFFE6F3EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextButton.icon(
                      icon: Icon(
                        Symbols.arrow_upward,
                        size: 16,
                        color: isDark ? AppColors.activeRed : const Color(0xFFD9383A),
                      ),
                      label: Text(
                        'Add Expense',
                        style: GoogleFonts.workSans(
                          fontSize: AppFontSizes.size13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.activeRed : const Color(0xFFD9383A),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.activeRed.withValues(alpha: 0.15)
                            : const Color(0xFFFDECEC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 12),
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
