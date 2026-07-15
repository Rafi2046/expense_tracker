import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';

class AllTransactionsList extends StatelessWidget {
  final bool isMasked;
  final bool isLoading;

  const AllTransactionsList({super.key, this.isMasked = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.filteredTransactions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('title'),
                        style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.translate('category')}  •  01 Jan 2024',
                        style: AppTextStyles.reportTransactionSubtitle.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳0,000',
                    style: AppTextStyles.reportTransactionTitle,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.transactionsIcon,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),
              Text(
                context.translate('no_transactions_matched_filters'),
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: isDark ? Colors.white60 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tx = filtered[index];
        final isCredit = tx.type == 'Income' || tx.type == 'Payment In';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tx.subtitle} • ${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                    style: AppTextStyles.reportTransactionSubtitle.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              PrivacyMaskedText(
                amount: tx.amount,
                isMasked: isMasked,
                style: AppTextStyles.reportTransactionTitle.copyWith(
                  color: isCredit ? theme.primaryColor : AppColors.activeRed,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
