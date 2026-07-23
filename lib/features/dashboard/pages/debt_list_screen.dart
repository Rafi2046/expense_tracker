import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_item_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class DebtListScreen extends StatelessWidget {
  final List<DebtItem> items;
  final String title;
  final Color themeColor;
  final bool isReceive;

  const DebtListScreen({
    super.key,
    required this.items,
    required this.title,
    required this.themeColor,
    required this.isReceive,
  });

  void _confirmDelete(BuildContext context, DebtItem item, DebtProvider provider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.dialogTheme.backgroundColor ?? theme.cardColor,
        title: Text(
          context.translate('delete_debt'),
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          context.translate('delete_debt_confirmation'),
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.translate('cancel'), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              provider.deleteDebtItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translate('debt_deleted', namedArgs: {'name': item.name})),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(context.translate('delete'), style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final debtProvider = context.read<DebtProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTextStyles.appbarTitle.copyWith(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
        itemBuilder: (context, index) {
          final item = items[index];
          return DebtItemRow(
            item: item,
            themeColor: themeColor,
            onEditTap: () => AddEditDebtSheet.show(
              context: context,
              item: item,
              payeeLabel: context.translate('payee_label'),
              themeColor: themeColor,
              isReceive: isReceive,
            ),
            onDelete: () => _confirmDelete(context, item, debtProvider),
          );
        },
      ),
    );
  }
}
