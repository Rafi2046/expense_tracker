import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_expense.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';


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
        title: Text('Invoice', style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_rounded),
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
                  _buildHeader(tour),
                  const SizedBox(height: 24),
                  _buildTotalSpentBadge(totalSpent, tour.currency, isDark),
                  if (!isAllSettled) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('PAYMENTS REQUIRED'),
                    const SizedBox(height: 16),
                    ..._buildSettlementList(settlements, pById, tour.currency, isDark),
                    const SizedBox(height: 32),
                  ],
                  if (isAllSettled) ...[
                    const SizedBox(height: 32),
                    _buildAllSettled(isDark),
                    const SizedBox(height: 32),
                  ],
                  _buildSectionTitle('WHERE THE MONEY WENT'),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdown(expenses, tour.currency, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('DETAILED LEDGER'),
                  const SizedBox(height: 16),
                  _buildLedgerList(expenses, pById, tour.currency, isDark),
                  if (expenses.any((e) => e.receiptPath != null && e.receiptPath!.isNotEmpty)) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('RECEIPTS'),
                    const SizedBox(height: 16),
                    _buildReceiptsGrid(expenses, isDark),
                  ],
                  const SizedBox(height: 32),
                  _buildFooter(),
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
        ShareParams(files: [XFile(file.path)], text: '${tour.name} — Detailed Invoice'),
      );
    } catch (_) {}
    if (mounted) setState(() => _isSharing = false);
  }

  Widget _buildHeader(Tour tour) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INVOICE', style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w800, color: AppColors.activeGreen, letterSpacing: 3)),
                const SizedBox(height: 6),
                Text(tour.name, style: AppTextStyles.displayLarge.copyWith(letterSpacing: -0.5, color: theme.colorScheme.onSurface)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatDate(tour.createdAt), style: AppTextStyles.caption.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                const SizedBox(height: 2),
                Text(tour.currency, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSpentBadge(double totalSpent, String currency, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.activeGreen.withValues(alpha: isDark ? 0.3 : 0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Text('TOTAL SPENT', style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF6B7280), letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(_formatAmount(totalSpent, currency), style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size36, fontWeight: FontWeight.w800, color: AppColors.activeGreen, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size10, fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF), letterSpacing: 2));
  }

  List<Widget> _buildSettlementList(List<SimplifiedSettlement> settlements, Map<String, String> pById, String currency, bool isDark) {
    return settlements.map((s) {
      final from = pById[s.fromParticipantId] ?? 'Unknown';
      final to = pById[s.toParticipantId] ?? 'Unknown';
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildPersonChip(from, isDark: isDark, color: AppColors.activeRed),
                const Spacer(),
                Text('pays', style: AppTextStyles.label.copyWith(color: const Color(0xFF9CA3AF))),
                const Spacer(),
                _buildPersonChip(to, isDark: isDark, color: AppColors.activeGreen),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.activeGreen.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatAmount(s.amount, currency),
                style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size18, fontWeight: FontWeight.w800, color: AppColors.activeGreen),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPersonChip(String name, {required bool isDark, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: AppTextStyles.bodyBold.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold.copyWith(color: isDark ? Colors.white : const Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  Widget _buildAllSettled(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.activeGreen.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.activeGreen, size: 44),
          const SizedBox(height: 12),
          Text('All settled up', style: AppTextStyles.h2.copyWith(color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46))),
          const SizedBox(height: 4),
          Text('No payments needed — everyone is even', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF6EE7B7).withValues(alpha: 0.7) : const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<TourExpense> expenses, String currency, bool isDark) {
    final cats = <String, double>{};
    for (final e in expenses) {
      final cat = e.category ?? 'Uncategorized';
      cats[cat] = (cats[cat] ?? 0) + e.amount;
    }
    final sorted = cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          ...sorted.map((e) {
            final total = cats.values.fold(0.0, (a, b) => a + b);
            final pct = total > 0 ? e.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151))),
                      Text(_formatAmount(e.value, currency), style: GoogleFonts.jetBrainsMono(fontSize: AppFontSizes.size13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF111827))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      color: AppColors.activeGreen,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLedgerList(List<TourExpense> expenses, Map<String, String> pById, String currency, bool isDark) {
    final sorted = List<TourExpense>.from(expenses)..sort((a, b) => b.date.compareTo(a.date));
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            color: AppColors.activeGreen,
            child: Row(
              children: [
                _ledgerCell('Date', flex: 2, isHeader: true),
                _ledgerCell('Expense', flex: 3, isHeader: true),
                _ledgerCell('Paid By', flex: 2, isHeader: true),
                _ledgerCell('Amount', flex: 2, align: TextAlign.right, isHeader: true),
              ],
            ),
          ),
          ...sorted.map((e) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFE5E7EB), width: 0.5)),
            ),
            child: Row(
              children: [
                _ledgerCell(_formatShortDate(e.date), flex: 2),
                _ledgerCell(e.title, flex: 3),
                _ledgerCell(pById[e.paidBy] ?? 'Unknown', flex: 2),
                _ledgerCell(_formatAmount(e.amount, currency), flex: 2, align: TextAlign.right, bold: true),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _ledgerCell(String text, {int flex = 1, TextAlign align = TextAlign.left, bool bold = false, bool isHeader = false}) {
    return Expanded(
      flex: flex,
      child: Text(text, textAlign: align,
        style: AppTextStyles.caption.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: isHeader ? Colors.white : (bold ? const Color(0xFF111827) : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  Widget _buildReceiptsGrid(List<TourExpense> expenses, bool isDark) {
    final withReceipts = expenses.where((e) => e.receiptPath != null && e.receiptPath!.isNotEmpty && File(e.receiptPath!).existsSync()).toList();
    if (withReceipts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < withReceipts.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildReceiptCard(withReceipts[i], isDark)),
                const SizedBox(width: 12),
                if (i + 1 < withReceipts.length)
                  Expanded(child: _buildReceiptCard(withReceipts[i + 1], isDark))
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReceiptCard(TourExpense e, bool isDark) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: Image.file(
              File(e.receiptPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 180,
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                child: Center(
                  child: Icon(Icons.broken_image_rounded, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), size: 36),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF374151)),
                ),
                const SizedBox(height: 2),
                Text(_formatShortDate(e.date), style: AppTextStyles.caption.copyWith(fontSize: AppFontSizes.size10, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_rounded, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text('Generated via Expense Tracker', style: AppTextStyles.caption.copyWith(fontSize: AppFontSizes.size9, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    const symbols = {'BDT': '\u09F3', 'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3', 'INR': '\u20B9', 'JPY': '\u00A5', 'AED': '\u062F.\u0625', 'CAD': r'$'};
    final sym = symbols[currency] ?? r'$';
    return amount == amount.roundToDouble()
        ? '$sym${amount.toStringAsFixed(0)}'
        : '$sym${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatShortDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
