import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/dashboard/widgets/balance_action_tile.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BalanceActionList extends StatelessWidget {
  final VoidCallback onAddReduceMoney;
  final VoidCallback onTransferBalance;

  const BalanceActionList({
    super.key,
    required this.onAddReduceMoney,
    required this.onTransferBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        BalanceActionTile(
          title: context.translate('add_reduce_money'),
          subtitle: context.translate('add_reduce_money_subtitle'),
          icon: LucideIcons.plus,
          iconBg: isDark ? AppColors.activeRed.withValues(alpha: 0.15) : const Color(0xFFFDECEC),
          iconColor: AppColors.activeRed,
          onTap: onAddReduceMoney,
        ),
        const SizedBox(height: 10),
        BalanceActionTile(
          title: context.translate('transfer_balance'),
          subtitle: context.translate('transfer_balance_subtitle'),
          icon: LucideIcons.arrowLeftRight,
          iconBg: isDark ? const Color(0xFF2980B9).withValues(alpha: 0.15) : const Color(0xFFEBF3F9),
          iconColor: const Color(0xFF2980B9),
          onTap: onTransferBalance,
        ),
      ],
    );
  }
}
