import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/model/party_statement_entry.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';

class PartyStatementDummyTableView extends StatelessWidget {
  final List<PartyStatementEntry> entries;
  final ThemeData theme;
  final bool isDark;

  const PartyStatementDummyTableView({
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
        _buildNetBalanceBanner(context),
        const SizedBox(height: AppSpacing.s24),
        _buildSummaryRow(context),
        const SizedBox(height: AppSpacing.s16),
        ...entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.p8),
              child: _buildTableRow(context, e),
            )),
      ],
    );
  }

  Widget _buildNetBalanceBanner(BuildContext context) {
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
          Text(context.translate('net_balance'),
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.s8),
          Text('৳ 5,300', style: AppTextStyles.displayMedium),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.translate('transactions'), style: AppTextStyles.reportStatLabel),
              const SizedBox(height: AppSpacing.s4),
              Text('5 entries', style: AppTextStyles.caption),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text(context.translate('debit'),
                  style: AppTextStyles.reportStatLabel
                      .copyWith(color: AppColors.activeGreen)),
              const SizedBox(height: AppSpacing.s4),
              Text('৳ 0,000',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.activeGreen)),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text(context.translate('credit'),
                  style: AppTextStyles.reportStatLabel
                      .copyWith(color: AppColors.activeRed)),
              const SizedBox(height: AppSpacing.s4),
              Text('৳ 0,000',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.activeRed)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(BuildContext context, PartyStatementEntry e) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.p8),
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.description,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.s4),
                Text(DateFormat('dd MMM yyyy').format(e.dateTime),
                    style: AppTextStyles.caption
                        ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: e.isInflow
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.activeGreen.withValues(alpha: 0.1)
                          : const Color(0xFFE8F8F5),
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.activeGreen.withValues(alpha: 0.2)
                            : const Color(0xFFD1F2E5),
                      ),
                    ),
                    child: Text('৳ ${e.amount.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.reportTransactionTitle.copyWith(
                            color: AppColors.activeGreen)),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 1,
            child: !e.isInflow
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.p8, vertical: AppSpacing.p8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.activeRed.withValues(alpha: 0.1)
                          : const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(AppSpacing.r12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.activeRed.withValues(alpha: 0.2)
                            : const Color(0xFFFAD1D1),
                      ),
                    ),
                    child: Text('৳ ${e.amount.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.reportTransactionTitle.copyWith(
                            color: AppColors.activeRed)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
