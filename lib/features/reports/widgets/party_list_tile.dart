import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/model/party_report_summary.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';

class PartyListTile extends StatelessWidget {
  final PartyReportSummary item;
  final bool isMasked;
  final bool isDark;
  final VoidCallback onTap;
  const PartyListTile({
    super.key,
    required this.item,
    required this.isMasked,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReceivable = item.netBalance >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : const Color(0xFFF1F2F4),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.initials,
                      style: AppTextStyles.reportTileTitle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.reportTransactionTitle.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.phone ?? "No phone"} • ${item.transactionCount} txs',
                      style: AppTextStyles.reportTransactionSubtitle.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isReceivable ? 'To Receive' : 'To Give',
                  style: AppTextStyles.reportStatLabel.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                PrivacyMaskedText(
                  amount: item.netBalance.abs(),
                  isMasked: isMasked,
                  style: AppTextStyles.reportTransactionTitle.copyWith(
                    color: item.netBalance == 0
                        ? (isDark ? Colors.white38 : Colors.grey.shade600)
                        : (isReceivable
                            ? theme.primaryColor
                            : AppColors.activeRed),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
