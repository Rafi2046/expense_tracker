import 'package:material_symbols_icons/symbols.dart';
import 'package:expense_tracker/core/constants/app_images.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/providers/reports_provider.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_card_view.dart';
import 'package:expense_tracker/features/reports/widgets/party_statement_table_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/model/party_statement_entry.dart';

class PartyStatementContent extends StatelessWidget {
  final bool isMasked;
  final bool isLoading;

  const PartyStatementContent({super.key, this.isMasked = false, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<ReportsProvider>();
    final partyName = reportsProvider.selectedPartyNameForStatement;
    final transactions = reportsProvider.partyStatementTransactions;

    final theme = Theme.of(context);

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
                style: AppTextStyles.reportAppBarTitle.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading) {
      return Skeletonizer(
        enabled: true,
        child: _buildDummyCardContent(context, reportsProvider.partyStatementViewMode),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.receipt_long_rounded, color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200, size: 72),
              const SizedBox(height: 16),
              Text(
                'No Transactions Found',
                style: AppTextStyles.reportTransactionSubtitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (reportsProvider.partyStatementViewMode == PartyStatementViewMode.card) {
      return PartyStatementCardView(isMasked: isMasked);
    } else {
      return PartyStatementTableView(isMasked: isMasked);
    }
  }

  Widget _buildDummyCardContent(BuildContext context, PartyStatementViewMode viewMode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dummyEntries = List.generate(5, (i) {
      return PartyStatementEntry(
        id: 'skel_$i',
        partyName: 'Party Name',
        description: 'Transaction description skeleton $i',
        amount: [500.0, 1200.0, 300.0, 2500.0, 800.0][i],
        isInflow: i.isEven,
        dateTime: DateTime.now().subtract(Duration(days: i)),
      );
    });

    if (viewMode == PartyStatementViewMode.card) {
      return _DummyCardView(entries: dummyEntries, theme: theme, isDark: isDark);
    } else {
      return _DummyTableView(entries: dummyEntries, theme: theme, isDark: isDark);
    }
  }
}

class _DummyCardView extends StatelessWidget {
  final List<PartyStatementEntry> entries;
  final ThemeData theme;
  final bool isDark;

  const _DummyCardView({required this.entries, required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.activeGreen.withValues(alpha: 0.15) : const Color(0xFFF4FBF9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.activeGreen.withValues(alpha: 0.3) : const Color(0xFFD3EFE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Receivables', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('৳ 5,300', style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FBF7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD8F3E5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Money In', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('৳ 0,000', style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFAD1D1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Money Out', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('৳ 0,000', style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Transactions', style: GoogleFonts.workSans(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ...entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: e.isInflow
                        ? (isDark ? AppColors.activeGreen.withValues(alpha: 0.14) : const Color(0xFFE6F9F0))
                        : (isDark ? AppColors.activeRed.withValues(alpha: 0.14) : const Color(0xFFFDE9EB)),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    e.isInflow ? Symbols.south_west_rounded : Symbols.north_east_rounded,
                    color: e.isInflow ? AppColors.activeGreen : AppColors.activeRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.description, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 5),
                      Text(DateFormat('dd MMM yyyy').format(e.dateTime),
                        style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.w400, color: isDark ? Colors.white38 : Colors.grey.shade500)),
                    ],
                  ),
                ),
                Text(
                  '${e.isInflow ? '+' : '−'} ৳ ${e.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.workSans(fontSize: 14.5, fontWeight: FontWeight.w700,
                    color: e.isInflow ? AppColors.activeGreen : AppColors.activeRed),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _DummyTableView extends StatelessWidget {
  final List<PartyStatementEntry> entries;
  final ThemeData theme;
  final bool isDark;

  const _DummyTableView({required this.entries, required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.activeGreen.withValues(alpha: 0.15) : const Color(0xFFF4FBF9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.activeGreen.withValues(alpha: 0.3) : const Color(0xFFD3EFE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Net Balance', style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('৳ 5,300', style: GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(flex: 2, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transactions', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('5 entries', style: GoogleFonts.workSans(fontSize: 11)),
              ],
            )),
            Expanded(flex: 1, child: Column(
              children: [
                Text('Debit', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.activeGreen)),
                const SizedBox(height: 4),
                Text('৳ 0,000', style: GoogleFonts.workSans(fontSize: 11, color: AppColors.activeGreen)),
              ],
            )),
            Expanded(flex: 1, child: Column(
              children: [
                Text('Credit', style: GoogleFonts.workSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.activeRed)),
                const SizedBox(height: 4),
                Text('৳ 0,000', style: GoogleFonts.workSans(fontSize: 11, color: AppColors.activeRed)),
              ],
            )),
          ],
        ),
        const SizedBox(height: 20),
        ...entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.description, style: GoogleFonts.workSans(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM yyyy').format(e.dateTime), style: GoogleFonts.workSans(fontSize: 10.5)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: e.isInflow
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD1F2E5)),
                        ),
                        child: Text('৳ ${e.amount.toStringAsFixed(0)}', textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.activeGreen)),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                flex: 1,
                child: !e.isInflow
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFAD1D1)),
                        ),
                        child: Text('৳ ${e.amount.toStringAsFixed(0)}', textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.activeRed)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
