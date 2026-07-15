import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';

class InvoiceSettlementCardWidget extends StatelessWidget {
  final String fromName;
  final String toName;
  final double amount;
  final String currency;
  final bool isDark;

  const InvoiceSettlementCardWidget({
    super.key,
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _PersonChip(name: fromName, isDark: isDark, color: AppColors.activeRed),
              const Spacer(),
              Text(context.translate('pays_label'), style: AppTextStyles.label.copyWith(color: const Color(0xFF9CA3AF))),
              const Spacer(),
              _PersonChip(name: toName, isDark: isDark, color: AppColors.activeGreen),
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
              formatAmount(amount, currency),
              style: GoogleFonts.jetBrainsMono(
                fontSize: AppFontSizes.size18,
                fontWeight: FontWeight.w800,
                color: AppColors.activeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  final String name;
  final bool isDark;
  final Color color;

  const _PersonChip({
    required this.name,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
          child: Text(
            name.isNotEmpty ? String.fromCharCode(name.runes.first).toUpperCase() : '?',
            style: AppTextStyles.bodyBold.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold.copyWith(
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}
