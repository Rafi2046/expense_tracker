import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_header_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_total_badge_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_section_title_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_settlement_card_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_all_settled_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_category_breakdown_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_ledger_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_receipts_grid_widget.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_footer_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class TourInvoiceScreen extends StatefulWidget {
  final String tourId;

  const TourInvoiceScreen({super.key, required this.tourId});

  @override
  State<TourInvoiceScreen> createState() => _TourInvoiceScreenState();
}

class _TourInvoiceScreenState extends State<TourInvoiceScreen> {
  final _screenshotController = ScreenshotController();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TourProvider>();
    final tour = provider.tours.firstWhere((t) => t.id == widget.tourId);
    final participants = provider.participants;
    final expenses = provider.expenses;
    final netBalances = provider.netBalances(widget.tourId);
    final totalSpent = provider.totalSpent(widget.tourId);
    final totalOutstanding = provider.totalOutstanding(widget.tourId);
    final settlements = simplifyDebts(netBalances);
    final pById = {for (final p in participants) p.id: p.name};
    final isAllSettled = totalOutstanding == 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categoryTotals = <String, double>{};
    for (final e in expenses) {
      final cat = e.category ?? context.translate('uncategorized');
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + e.amount;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        shape: Border(
          bottom: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
        title: Text(context.translate('invoice_title'), style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(LucideIcons.share),
            onPressed: _isSharing ? null : () => _shareInvoice(tour, participants, expenses, settlements, totalSpent, totalOutstanding),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(context).padding.bottom + 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InvoiceHeaderWidget(
                    tourName: tour.name,
                    formattedDate: formatDate(tour.createdAt),
                    currency: tour.currency,
                  ),
                  const SizedBox(height: 24),
                  InvoiceTotalBadgeWidget(
                    totalSpent: totalSpent,
                    currency: tour.currency,
                    isDark: isDark,
                  ),
                  if (!isAllSettled) ...[
                    const SizedBox(height: 32),
                    InvoiceSectionTitleWidget(title: context.translate('payments_required_section')),
                    const SizedBox(height: 16),
                    ...settlements.map((s) => InvoiceSettlementCardWidget(
                      fromName: pById[s.fromParticipantId] ?? context.translate('unknown_member'),
                      toName: pById[s.toParticipantId] ?? context.translate('unknown_member'),
                      amount: s.amount,
                      currency: tour.currency,
                      isDark: isDark,
                    )),
                    const SizedBox(height: 32),
                  ],
                  if (isAllSettled) ...[
                    const SizedBox(height: 32),
                    InvoiceAllSettledWidget(isDark: isDark),
                    const SizedBox(height: 32),
                  ],
                  InvoiceSectionTitleWidget(title: context.translate('where_the_money_went')),
                  const SizedBox(height: 16),
                  InvoiceCategoryBreakdownWidget(
                    categoryTotals: categoryTotals,
                    currency: tour.currency,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  InvoiceSectionTitleWidget(title: context.translate('detailed_ledger_section')),
                  const SizedBox(height: 16),
                  InvoiceLedgerWidget(
                    expenses: expenses,
                    participantNames: pById,
                    currency: tour.currency,
                    isDark: isDark,
                  ),
                  if (expenses.any((e) => e.receiptPaths.isNotEmpty)) ...[
                    const SizedBox(height: 32),
                    InvoiceSectionTitleWidget(title: context.translate('receipts_section')),
                    const SizedBox(height: 16),
                    InvoiceReceiptsGridWidget(expenses: expenses, isDark: isDark),
                  ],
                  const SizedBox(height: 32),
                  InvoiceFooterWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareInvoice(
    Tour tour,
    List<TourParticipant> participants,
    List<TourExpense> expenses,
    List<SimplifiedSettlement> settlements,
    double totalSpent,
    double totalOutstanding,
  ) async {
    setState(() => _isSharing = true);
    try {
      final imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );
      if (imageBytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tour_invoice_${tour.id.substring(0, 8)}.png');
      await file.writeAsBytes(imageBytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: context.translate('share_invoice_text', namedArgs: {'name': tour.name})),
      );
    } catch (_) {}
    if (mounted) setState(() => _isSharing = false);
  }
}
