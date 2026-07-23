import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart' show AppImages;
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/debt_provider.dart';
import 'package:expense_tracker/features/dashboard/pages/debt_list_screen.dart';
import 'package:expense_tracker/features/dashboard/widgets/add_edit_debt_sheet.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_item_row.dart';
import 'package:expense_tracker/features/dashboard/widgets/debt_total_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class ToGiveScreen extends StatefulWidget {
  const ToGiveScreen({super.key});

  @override
  State<ToGiveScreen> createState() => _ToGiveScreenState();
}

class _ToGiveScreenState extends State<ToGiveScreen> {
  static bool _localMasked = false;
  bool _showGuide = true;

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
    final debtProvider = context.watch<DebtProvider>();
    final items = debtProvider.toGiveUnpaid;
    final displayItems = items.length > 4 ? items.sublist(0, 4) : items;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          context.translate('to_give'),
          style: AppTextStyles.appbarTitle.copyWith(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.p16, AppSpacing.p16, AppSpacing.p16, AppSpacing.p4),
              child: DebtTotalCard(
                title: context.translate('total_you_owe'),
                amount: debtProvider.totalToGive,
                gradientColors: const [Color(0xFFB01D2E), Color(0xFFDC3545)],
                guideText: context.translate('guide_swipe_settle'),
                showGuide: _showGuide,
                onDismissGuide: () {
                  setState(() {
                    _showGuide = false;
                  });
                },
                cardIcon: LucideIcons.arrowUp,
                isMasked: _localMasked,
                onToggleMask: () => setState(() => _localMasked = !_localMasked),
              ),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.p16, right: AppSpacing.p16, top: AppSpacing.p8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.translate('active_payables'),
                          style: AppTextStyles.sectionHeaderTitle.copyWith(color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p8,
                            vertical: AppSpacing.p4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.activeRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.r12),
                          ),
                          child: Text(
                            '${items.length}',
                            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.activeRed),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DebtListScreen(
                              items: items,
                              title: context.translate('all_payables'),
                              themeColor: AppColors.activeRed,
                              isReceive: false,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p12, vertical: AppSpacing.p4),
                        foregroundColor: AppColors.activeRed,
                        textStyle: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.activeRed),
                      ),
                      child: Text(context.translate('see_all')),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
                      child: Column(
                        children: [
                          const Spacer(),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppImages.pendingPayments,
                                height: 120,
                                width: 120,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              Text(
                                context.translate('no_pending_debts'),
                                style: AppTextStyles.reportTileTitle.copyWith(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const Spacer(),
                          _buildInlineAddButton(context, theme),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayItems.length + 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.p16,
                        vertical: AppSpacing.p8,
                      ),
                      itemBuilder: (context, index) {
                        if (index == displayItems.length) {
                          return _buildInlineAddButton(context, theme);
                        }
                        final item = displayItems[index];
                        return DebtItemRow(
                          item: item,
                          themeColor: AppColors.activeRed,
                          isMasked: _localMasked,
                          onEditTap: () => AddEditDebtSheet.show(
                            context: context,
                            item: item,
                            payeeLabel: context.translate('payee_label'),
                            themeColor: AppColors.activeRed,
                            isReceive: false,
                          ),
                          onDelete: () => _confirmDelete(context, item, debtProvider),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineAddButton(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.p8, 0, AppSpacing.p16),
      child: GestureDetector(
        onTap: () => AddEditDebtSheet.show(
          context: context,
          payeeLabel: context.translate('payee_label'),
          themeColor: AppColors.activeRed,
          isReceive: false,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.activeRed.withValues(alpha: 0.06)
                : AppColors.activeRed.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppSpacing.r12),
            border: Border.all(
              color: isDark
                  ? AppColors.activeRed.withValues(alpha: 0.2)
                  : AppColors.activeRed.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.plus, size: 18, color: AppColors.activeRed),
              const SizedBox(width: AppSpacing.s8),
              Text(
                context.translate('add_new'),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600,
                  color: AppColors.activeRed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
