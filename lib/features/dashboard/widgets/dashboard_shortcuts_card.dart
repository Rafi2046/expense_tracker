import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/edit_shortcuts_sheet.dart';
import 'package:expense_tracker/features/dashboard/pages/add_party_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardShortcutsCard extends StatelessWidget {
  const DashboardShortcutsCard({super.key});

  Widget _buildShortcutIcon(String id) {
    const Color activeGreen = AppColors.activeGreen;
    switch (id) {
      case 'payment_out':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(
                Symbols.account_balance_wallet,
                size: 18,
                color: activeGreen,
              ),
            ),
            Positioned(
              top: 0,
              child: Icon(Symbols.arrow_upward, size: 9, color: activeGreen),
            ),
          ],
        );
      case 'income':
        return const Icon(
          Symbols.payments,
          size: 20,
          color: activeGreen,
        );
      case 'expense':
        return const Icon(
          Symbols.account_balance_wallet,
          size: 20,
          color: activeGreen,
        );
      case 'payment_in':
        return const Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Icon(
                Symbols.account_balance_wallet,
                size: 18,
                color: activeGreen,
              ),
            ),
            Positioned(
              top: 0,
              child: Icon(Symbols.arrow_downward, size: 9, color: activeGreen),
            ),
          ],
        );
      case 'add_party':
        return const Icon(
          Symbols.person_add,
          size: 20,
          color: activeGreen,
        );
      default:
        return const Icon(Symbols.help_outline, size: 20, color: activeGreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcutProvider = context.watch<ShortcutProvider>();
    final activeShortcuts = shortcutProvider.activeShortcuts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('quick_actions'),
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => EditShortcutsSheet.show(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Symbols.edit_square,
                      size: 13,
                      color: AppColors.activeGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.translate('edit_menu'),
                      style: GoogleFonts.workSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Container Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? const Color(0xFFF0F0F0),
              width: 1,
            ),
          ),
          child: activeShortcuts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'No quick actions enabled. Tap "Edit Menu" to add some.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                )
              : _buildGrid(context, activeShortcuts),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context, List<ShortcutItem> activeShortcuts) {
    final List<List<ShortcutItem>> chunks = [];
    for (var i = 0; i < activeShortcuts.length; i += 3) {
      final end = (i + 3 > activeShortcuts.length)
          ? activeShortcuts.length
          : i + 3;
      chunks.add(activeShortcuts.sublist(i, end));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int rowIndex = 0; rowIndex < chunks.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: 12),
          Row(
            children: [
              for (int colIndex = 0; colIndex < 3; colIndex++) ...[
                if (colIndex < chunks[rowIndex].length)
                  Expanded(
                    child: _buildShortcutItem(
                      context,
                      chunks[rowIndex][colIndex],
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildShortcutItem(BuildContext context, ShortcutItem item) {
    return GestureDetector(
      onTap: () {
        if (item.id == 'add_party') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPartyScreen()),
          );
        } else if (item.id == 'expense') {
          AddTransactionSheet.show(context: context, isIncome: false);
        } else if (item.id == 'income') {
          AddTransactionSheet.show(context: context, isIncome: true);
        } else if (item.id == 'payment_out') {
          AddEditDebtSheet.show(
            context: context,
            payeeLabel: 'Payee Name',
            themeColor: AppColors.activeRed,
            isReceive: false,
          );
        } else if (item.id == 'payment_in') {
          AddEditDebtSheet.show(
            context: context,
            payeeLabel: 'Client/Friend Name',
            themeColor: AppColors.buttonColor,
            isReceive: true,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.label} shortcut clicked'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round Icon Container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.activeGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(child: _buildShortcutIcon(item.id)),
          ),
          const SizedBox(height: 6),
          // Label
          Text(
            context.translate(item.id),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.workSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}
