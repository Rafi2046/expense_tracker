import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/providers/shortcut_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_transaction_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/edit_shortcuts_sheet.dart';
import 'package:expense_tracker/features/dashboard/pages/add_party_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


class DashboardShortcutsCard extends StatelessWidget {
  const DashboardShortcutsCard({super.key});

  /// Soft fill pairs from ColorScheme containers — no orphan purple/amber.
  List<Color> _gradient(String id, ColorScheme scheme) {
    switch (id) {
      case 'income':
        return [scheme.primaryContainer, scheme.secondaryContainer];
      case 'expense':
        return [scheme.errorContainer, scheme.errorContainer.withValues(alpha: 0.7)];
      case 'payment_in':
        return [scheme.secondaryContainer, scheme.primaryContainer];
      case 'payment_out':
        return [scheme.tertiaryContainer, scheme.errorContainer.withValues(alpha: 0.5)];
      case 'add_party':
        return [scheme.primaryContainer, scheme.tertiaryContainer];
      default:
        return [scheme.surfaceContainerHighest, scheme.surfaceContainer];
    }
  }

  Color _iconColor(String id, ColorScheme scheme) {
    switch (id) {
      case 'income':
        return scheme.primary;
      case 'expense':
        return scheme.error;
      case 'payment_in':
        return scheme.secondary;
      case 'payment_out':
        return scheme.tertiary;
      case 'add_party':
        return scheme.primary;
      default:
        return scheme.primary;
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    context.watch<LanguageProvider>();

    final addParty = activeShortcuts.where((s) => s.id == 'add_party').toList();
    final gridItems = activeShortcuts.where((s) => s.id != 'add_party').toList();

    final cardBg = theme.cardColor;
    final dividerColor = theme.dividerTheme.color ?? scheme.outline;
    final labelColor = scheme.onSurface;
    final subLabelColor = scheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.r8),
        border: Border.all(
          color: dividerColor,
          width: AppSpacing.w1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.translate('quick_actions'),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: scheme.onSurface),
              ),
              GestureDetector(
                onTap: () => EditShortcutsSheet.show(context),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  context.translate('edit_menu'),
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600,
                    color: labelColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          if (gridItems.isEmpty)
            for (final item in addParty)
              _buildRowItem(context, item, scheme, subLabelColor)
          else ...[
            Row(
              children: [
                for (final item in gridItems) ...[
                  Expanded(child: _buildGridItem(context, item, scheme, labelColor)),
                ],
              ],
            ),
            if (addParty.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
                child: Container(height: 1, color: dividerColor),
              ),
              for (final item in addParty)
                _buildRowItem(context, item, scheme, subLabelColor),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    ShortcutItem item,
    ColorScheme scheme,
    Color labelColor,
  ) {
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
                colors: _gradient(item.id, scheme),
              ),
            ),
            child: Icon(_icon(item.id), size: 17, color: _iconColor(item.id, scheme)),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            context.translate(item.id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600,
              color: labelColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(
    BuildContext context,
    ShortcutItem item,
    ColorScheme scheme,
    Color subLabelColor,
  ) {
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
                colors: _gradient(item.id, scheme),
              ),
            ),
            child: Icon(_icon(item.id), size: 17, color: _iconColor(item.id, scheme)),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate(item.id),
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
                    color: scheme.onSurface),
                ),
                Text(
                  context.translate('always_on'),
                  style: AppTextStyles.caption.copyWith(color: subLabelColor),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, ShortcutItem item) {
    final scheme = Theme.of(context).colorScheme;
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
        payeeLabel: context.translate('payee_name'),
        themeColor: scheme.error,
        isReceive: false,
      );
    } else if (item.id == 'payment_in') {
      AddEditDebtSheet.show(
        context: context,
        payeeLabel: context.translate('client_friend_name'),
        themeColor: scheme.primary,
        isReceive: true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('shortcut_clicked', namedArgs: {'label': context.translate(item.id)})),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
