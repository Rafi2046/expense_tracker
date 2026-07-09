import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';

class PartyStatementList extends StatelessWidget {
  const PartyStatementList({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;
    final currencySymbol = context.currencySymbol;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (partyName == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.partyReportIcon, width: 150, height: 200),
              const SizedBox(height: 16),
              Text(
                'Select Party to View Report',
                style: AppTextStyles.reportAppBar.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No transactions in this period',
            style: AppTextStyles.reportTransactionSubtitle.copyWith(
              fontSize: AppFontSizes.size14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Lists',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w700,
            fontSize: AppFontSizes.size15,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = transactions[index];

            final isInflow = entry.isInflow;
            final typeColor = isInflow ? AppColors.activeGreen : AppColors.activeRed;

            // Leading icon badge
            final IconData leadingIcon;
            final Color iconBgColor;
            final Color iconFgColor;

            if (isInflow) {
              leadingIcon = Symbols.south_west_rounded;
              iconBgColor = isDark
                  ? AppColors.activeGreen.withValues(alpha: 0.14)
                  : const Color(0xFFE6F9F0);
              iconFgColor = AppColors.activeGreen;
            } else {
              leadingIcon = Symbols.north_east_rounded;
              iconBgColor = isDark
                  ? AppColors.activeRed.withValues(alpha: 0.14)
                  : const Color(0xFFFDE9EB);
              iconFgColor = AppColors.activeRed;
            }

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Row(
                children: [
                  // ── Leading Icon Badge ──
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      leadingIcon,
                      color: iconFgColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Center Column: Title + Date ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('dd MMM yyyy').format(entry.dateTime),
                          style: GoogleFonts.workSans(
                            fontSize: AppFontSizes.size11,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ── Trailing: Amount ──
                  Text(
                    '${isInflow ? '+' : '−'} $currencySymbol ${entry.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.workSans(
                      fontSize: AppFontSizes.size15,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                      letterSpacing: -0.2,
                    ),
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
