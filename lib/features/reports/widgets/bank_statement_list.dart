import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class BankStatementList extends StatelessWidget {
  final bool isMasked;

  const BankStatementList({super.key, this.isMasked = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final filtered = reportsProvider.bankStatementTransactions;
    final theme = Theme.of(context);

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset(AppImages.noTransactions,width: 160,height: 160,),
              const SizedBox(height: 16),
              Text(
                'No Transaction Found',
                style: AppTextStyles.reportAppBarTitle.copyWith(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Lists',
          style: AppTextStyles.reportTransactionTitle.copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final tx = filtered[index];

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: AppTextStyles.reportTransactionTitle.copyWith(fontSize: AppFontSizes.size14, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tx.subtitle}\n${DateFormat('dd MMM yyyy').format(tx.dateTime)}',
                          style: AppTextStyles.reportTransactionSubtitle.copyWith(
                            fontSize: AppFontSizes.size11,
                            height: 1.25,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bal: ',
                              style: AppTextStyles.reportStatLabel.copyWith(
                                color: theme.primaryColor,
                                fontSize: AppFontSizes.size11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            PrivacyMaskedText(
                              amount: tx.runningBalance,
                              style: AppTextStyles.reportStatLabel.copyWith(
                                color: theme.primaryColor,
                                fontSize: AppFontSizes.size11,
                                fontWeight: FontWeight.w600,
                              ),
                              isMasked: isMasked,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PrivacyMaskedText(
                    amount: tx.amount,
                    style: AppTextStyles.reportTransactionTitle.copyWith(
                      fontSize: AppFontSizes.size14,
                      color: tx.isCredit ? theme.primaryColor : AppColors.activeRed,
                    ),
                    isMasked: isMasked,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
