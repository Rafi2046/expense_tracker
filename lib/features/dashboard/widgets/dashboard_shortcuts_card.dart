import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/edit_shortcuts_sheet.dart';
import 'package:expense_tracker/features/dashboard/pages/add_party_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DashboardShortcutsCard extends StatelessWidget {
  const DashboardShortcutsCard({super.key});

  // Soft gradient pair per action — gives the icon circle a little depth
  List<Color> _gradient(String id, bool isDark) {
    switch (id) {
      case 'income':
        return isDark
            ? [const Color(0xFF16321F), const Color(0xFF1D4029)]
            : [const Color(0xFFE8F9EE), const Color(0xFFD5F2E0)];
      case 'expense':
        return isDark
            ? [const Color(0xFF3A1E1A), const Color(0xFF4A2620)]
            : [const Color(0xFFFDEDEA), const Color(0xFFFBDCD5)];
      case 'payment_in':
        return isDark
            ? [const Color(0xFF17253F), const Color(0xFF1E3050)]
            : [const Color(0xFFEAF1FE), const Color(0xFFD6E4FC)];
      case 'payment_out':
        return isDark
            ? [const Color(0xFF3A2A14), const Color(0xFF4A3419)]
            : [const Color(0xFFFEF3E8), const Color(0xFFFCE4C8)];
      case 'add_party':
        return isDark
            ? [const Color(0xFF2E2140), const Color(0xFF3A2B52)]
            : [const Color(0xFFF3EBFC), const Color(0xFFE7D5F9)];
      default:
        return [Colors.grey.shade200, Colors.grey.shade300];
    }
  }

  Color _iconColor(String id) {
    switch (id) {
      case 'income':
        return const Color(0xFF16A34A);
      case 'expense':
        return const Color(0xFFDC2626);
      case 'payment_in':
        return const Color(0xFF2563EB);
      case 'payment_out':
        return const Color(0xFFEA580C);
      case 'add_party':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.activeGreen;
    }
  }

  IconData _icon(String id) {
    switch (id) {
      case 'income':
        return LucideIcons.arrowDown;
      case 'expense':
        return LucideIcons.arrowUp;
      case 'payment_in':
      case 'payment_out':
        return LucideIcons.wallet;
      case 'add_party':
        return LucideIcons.userPlus;
      default:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcutProvider = context.watch<ShortcutProvider>();
    final activeShortcuts = shortcutProvider.activeShortcuts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Add Party is always-on and gets its own row treatment, so split it out
    final addParty = activeShortcuts.where((s) => s.id == 'add_party').toList();
    final gridItems = activeShortcuts.where((s) => s.id != 'add_party').toList();

    final cardBg = Theme.of(context).cardColor;
    final dividerColor = Theme.of(context).dividerTheme.color ?? AppColors.dividerColor;
    final labelColor = Theme.of(context).colorScheme.onSurface;
    final subLabelColor = AppColors.textMuted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? AppColors.dividerColor,
          width: AppSpacing.w1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('quick_actions'),
                style: GoogleFonts.workSans(
                  fontSize: AppFontSizes.size15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => EditShortcutsSheet.show(context),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  context.translate('edit_menu'),
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size12,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (gridItems.isEmpty)
            for (final item in addParty)
              _buildRowItem(context, item, isDark, subLabelColor)
          else ...[
            Row(
              children: [
                for (final item in gridItems) ...[
                  Expanded(child: _buildGridItem(context, item, isDark, labelColor)),
                ],
              ],
            ),
            if (addParty.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(height: 1, color: dividerColor),
              ),
              for (final item in addParty)
                _buildRowItem(context, item, isDark, subLabelColor),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, ShortcutItem item, bool isDark, Color labelColor) {
    return GestureDetector(
      onTap: () => _handleTap(context, item),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradient(item.id, isDark),
              ),
            ),
            child: Icon(_icon(item.id), size: 17, color: _iconColor(item.id)),
          ),
          const SizedBox(height: 8),
          Text(
            context.translate(item.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: AppFontSizes.size10,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(BuildContext context, ShortcutItem item, bool isDark, Color subLabelColor) {
    return GestureDetector(
      onTap: () => _handleTap(context, item),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradient(item.id, isDark),
              ),
            ),
            child: Icon(_icon(item.id), size: 17, color: _iconColor(item.id)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate(item.id),
                  style: GoogleFonts.workSans(
                    fontSize: AppFontSizes.size13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  context.translate('always_on'),
                  style: GoogleFonts.workSans(fontSize: AppFontSizes.size10, color: subLabelColor),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, ShortcutItem item) {
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
  }
}