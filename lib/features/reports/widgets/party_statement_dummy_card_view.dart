import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/model/party_statement_entry.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class PartyStatementDummyCardView extends StatelessWidget {
  final List<PartyStatementEntry> entries;
  final ThemeData theme;
  final bool isDark;

  const PartyStatementDummyCardView({
    super.key,
    required this.entries,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBalanceBanner(context),
        const SizedBox(height: AppSpacing.s12),
        _buildMoneyFlowRow(context),
        const SizedBox(height: AppSpacing.s24),
        Text(context.translate('transactions'), style: AppTextStyles.reportTransactionTitle),
        const SizedBox(height: AppSpacing.s12),
        ...entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.p8),
              child: _buildTransactionTile(context, e),
            )),
      ],
    );
  }

  Widget _buildBalanceBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.activeGreen.withValues(alpha: 0.15)
            : const Color(0xFFF4FBF9),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
            color: isDark
                ? AppColors.activeGreen.withValues(alpha: 0.3)
                : const Color(0xFFD3EFE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.translate('total_receivables'),
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.s8),
          Text('৳ 5,300', style: AppTextStyles.displayMedium),
        ],
      ),
    );
  }

  Widget _buildMoneyFlowRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.p12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.activeGreen.withValues(alpha: 0.1)
                  : const Color(0xFFF2FBF7),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              border: Border.all(
                color: isDark
                    ? AppColors.activeGreen.withValues(alpha: 0.2)
                    : const Color(0xFFD8F3E5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.translate('money_in'),
                    style: AppTextStyles.reportStatLabel
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.s4),
                Text('৳ 0,000', style: AppTextStyles.bodyBold),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.p12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.activeRed.withValues(alpha: 0.1)
                  : const Color(0xFFFFF5F5),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
              border: Border.all(
                color: isDark
                    ? AppColors.activeRed.withValues(alpha: 0.2)
                    : const Color(0xFFFAD1D1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.translate('money_out'),
                    style: AppTextStyles.reportStatLabel
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.s4),
                Text('৳ 0,000', style: AppTextStyles.bodyBold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, PartyStatementEntry e) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: e.isInflow
                  ? (isDark
                      ? AppColors.activeGreen.withValues(alpha: 0.14)
                      : const Color(0xFFE6F9F0))
                  : (isDark
                      ? AppColors.activeRed.withValues(alpha: 0.14)
                      : const Color(0xFFFDE9EB)),
              borderRadius: BorderRadius.circular(AppSpacing.r12),
            ),
            child: Icon(
              e.isInflow ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              color: e.isInflow ? AppColors.activeGreen : AppColors.activeRed,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold
                        .copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: AppSpacing.s4),
                Text(DateFormat('dd MMM yyyy').format(e.dateTime),
                    style: AppTextStyles.caption.copyWith(
                        color: isDark ? Colors.white38 : Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            '${e.isInflow ? '+' : '−'} ৳ ${e.amount.toStringAsFixed(0)}',
            style: AppTextStyles.reportTransactionTitle.copyWith(
                color: e.isInflow
                    ? AppColors.activeGreen
                    : AppColors.activeRed),
          ),
        ],
      ),
    );
  }
}
