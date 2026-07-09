import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BudgetManagementHeader extends StatelessWidget {
  final double monthlyExpense;
  final double budgetAmount;
  final bool hasBudget;
  final VoidCallback onEditBudget;

  const BudgetManagementHeader({
    super.key,
    required this.monthlyExpense,
    required this.budgetAmount,
    required this.hasBudget,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.currencySymbol;
    final percentage = hasBudget && budgetAmount > 0
        ? (monthlyExpense / budgetAmount * 100).clamp(0.0, 100.0).toDouble()
        : 0.0;
    final remaining = hasBudget
        ? (budgetAmount - monthlyExpense).clamp(0.0, double.infinity).toDouble()
        : 0.0;
    final isOver = hasBudget && monthlyExpense > budgetAmount;
    final progressColor = isOver
        ? AppColors.activeRed
        : percentage > 80
        ? const Color(0xFFF59E0B)
        : AppColors.activeGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.p20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C4E3C), Color(0xFF146C48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.br12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.p8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.br10),
                ),
                child: const Icon(
                  LucideIcons.wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.w12),
              Text(
                'Budget Overview',
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: AppFontSizes.size13,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEditBudget,
                borderRadius: BorderRadius.circular(AppSpacing.br8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.p12,
                    vertical: AppSpacing.p6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.br8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.edit, color: Colors.white, size: 14),
                      const SizedBox(width: AppSpacing.w4),
                      Text(
                        'Edit',
                        style: AppTextStyles.cardStatusText.copyWith(
                          color: Colors.white,
                          fontSize: AppFontSizes.size12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          Row(
            children: [
              _HeaderStat(
                label: 'Total Budget',
                value: hasBudget
                    ? '$currency ${_formatAmount(budgetAmount)}'
                    : 'Not set',
                color: Colors.white70,
              ),
              const Spacer(),
              if (hasBudget)
                _HeaderStat(
                  label: 'Spent',
                  value: '$currency ${_formatAmount(monthlyExpense)}',
                  color: isOver ? AppColors.activeRed : Colors.white,
                ),
              const Spacer(),
              if (hasBudget)
                _HeaderStat(
                  label: 'Remaining',
                  value: '$currency ${_formatAmount(remaining)}',
                  color: isOver ? AppColors.activeRed : const Color(0xFF2EBD85),
                ),
            ],
          ),
          if (hasBudget) ...[
            const SizedBox(height: AppSpacing.s16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.br4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              '${percentage.toStringAsFixed(1)}% used',
              style: AppTextStyles.cardStatusText.copyWith(
                color: Colors.white70,
                fontSize: AppFontSizes.size11,
              ),
            ),
          ],
          if (!hasBudget) ...[
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onEditBudget,
                icon: const Icon(
                  LucideIcons.plusCircle,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Set Monthly Budget',
                  style: AppTextStyles.cardStatusText.copyWith(
                    color: Colors.white,
                    fontSize: AppFontSizes.size13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000)
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k';
    return amount.toStringAsFixed(0);
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeaderStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.cardTitle.copyWith(
            color: Colors.white60,
            fontSize: AppFontSizes.size9,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          style: AppTextStyles.cardValueGreen.copyWith(
            color: color,
            fontSize: AppFontSizes.size16,
          ),
        ),
      ],
    );
  }
}
