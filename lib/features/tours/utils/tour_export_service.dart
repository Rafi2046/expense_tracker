import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/models/tour.dart';
import 'package:expense_tracker/core/models/tour_participant.dart';
import 'package:expense_tracker/core/utils/debt_simplifier.dart';
import 'package:expense_tracker/core/providers/tour_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TourExportService {
  static Future<void> shareReport(BuildContext context, String tourId) async {
    final provider = context.read<TourProvider>();
    final tour = provider.tours.firstWhere((t) => t.id == tourId);
    final participants = provider.participants;
    final netBalances = provider.netBalances(tourId);
    final totalSpent = provider.totalSpent(tourId);
    final totalOutstanding = provider.totalOutstanding(tourId);
    final settlements = simplifyDebts(netBalances);

    final controller = ScreenshotController();
    final receiptWidget = _buildReceipt(
      tour,
      participants,
      settlements,
      totalSpent,
      totalOutstanding,
    );

    final mediaQueryData = MediaQuery.of(context);
    final imageBytes = await controller.captureFromWidget(
      MediaQuery(
        data: mediaQueryData,
        child: Material(child: SizedBox(width: 420, child: receiptWidget)),
      ),
      pixelRatio: 3.0,
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/tour_report_${tour.id.substring(max(0, tour.id.length - 8))}.png',
    );
    await file.writeAsBytes(imageBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '${tour.name} \u2014 Settlement Report',
      ),
    );
  }

  static Widget _buildReceipt(
    Tour tour,
    List<TourParticipant> participants,
    List<SimplifiedSettlement> settlements,
    double totalSpent,
    double totalOutstanding,
  ) {
    final pById = {for (final p in participants) p.id: p.name};
    final isAllSettled = totalOutstanding == 0;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(tour),
          const SizedBox(height: AppSpacing.s24),
          _buildTotalSpentBadge(totalSpent, tour.currency),
          const SizedBox(height: AppSpacing.s24),
          _buildDivider(),
          const SizedBox(height: AppSpacing.s20),
          _buildSectionLabel(
            isAllSettled ? 'SETTLEMENT STATUS' : 'PAYMENTS REQUIRED',
          ),
          const SizedBox(height: AppSpacing.s16),
          if (isAllSettled)
            _buildAllSettled()
          else
            ..._buildSettlementList(settlements, pById, tour.currency),
          const SizedBox(height: AppSpacing.s24),
          _buildDivider(),
          const SizedBox(height: AppSpacing.s20),
          _buildFooter(),
        ],
      ),
    );
  }

  static Widget _buildHeader(Tour tour) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p20,
            vertical: AppSpacing.p10,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.r25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.receipt,
                size: 16,
                color: AppColors.white,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'SETTLEMENT REPORT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: AppFontSizes.size10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 3.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        Text(
          tour.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.displayLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  static Widget _buildTotalSpentBadge(double totalSpent, String currency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.p20,
        horizontal: AppSpacing.p24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(
          color: AppColors.activeGreen.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SPENT',
            style: AppTextStyles.summaryCardLabel.copyWith(
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            _formatAmount(totalSpent, currency),
            style: GoogleFonts.jetBrainsMono(
              fontSize: AppFontSizes.size32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF059669),
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFE5E7EB),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        fontSize: AppFontSizes.size10,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9CA3AF),
        letterSpacing: 2.0,
      ),
    );
  }

  static Widget _buildAllSettled() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.p24,
        horizontal: AppSpacing.p20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF9),
        borderRadius: BorderRadius.circular(AppSpacing.r16),
        border: Border.all(color: AppColors.activeGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.checkCircle,
            color: AppColors.activeGreen,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            tr('all_settled_up'),
            style: AppTextStyles.h2.copyWith(
              color: const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            tr('no_payments_needed'),
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  static List<Widget> _buildSettlementList(
    List<SimplifiedSettlement> settlements,
    Map<String, String> pById,
    String currency,
  ) {
    return settlements.asMap().entries.map((entry) {
      final s = entry.value;
      final from = pById[s.fromParticipantId] ?? tr('unknown_member');
      final to = pById[s.toParticipantId] ?? tr('unknown_member');

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        padding: const EdgeInsets.all(AppSpacing.p16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildPersonBadge(from, true),
                const Spacer(),
                Column(
                  children: [
                    Icon(
                      LucideIcons.arrowDown,
                      size: 18,
                      color: AppColors.activeGreen,
                    ),
                    Text(
                      _formatAmount(s.amount, currency),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: AppFontSizes.size16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildPersonBadge(to, false),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  static Widget _buildPersonBadge(String name, bool isPayer) {
    final bgColor = isPayer
        ? AppColors.activeRed.withValues(alpha: 0.08)
        : AppColors.activeGreen.withValues(alpha: 0.08);
    final textColor = isPayer ? AppColors.activeRed : AppColors.activeGreen;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: bgColor,
          child: Text(
            name.isNotEmpty ? String.fromCharCode(name.runes.first).toUpperCase() : '?',
            style: AppTextStyles.bodyBold.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.wallet,
          size: 14,
          color: Colors.grey.shade400,
        ),
        const SizedBox(width: AppSpacing.s6),
        Flexible(
          child: Text(
            tr('generated_via_budgetmint_footer'),
            style: AppTextStyles.caption.copyWith(
              fontSize: AppFontSizes.size9,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatAmount(double amount, String currency) {
    const symbols = {
      'BDT': '\u09F3',
      'USD': r'$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'INR': '\u20B9',
      'JPY': '\u00A5',
      'AED': '\u062F.\u0625',
      'CAD': r'$',
    };
    final sym = symbols[currency] ?? r'$';
    if (amount == amount.roundToDouble()) {
      return '$sym${amount.toStringAsFixed(0)}';
    }
    return '$sym${amount.toStringAsFixed(2)}';
  }
}
