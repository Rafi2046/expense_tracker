import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/features/tours/widgets/invoice_format_utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class InvoiceSettlementCardWidget extends StatelessWidget {
  final String fromName;
  final String toName;
  final double amount;
  final String currency;
  final bool isDark;
  final VoidCallback? onTap;

  const InvoiceSettlementCardWidget({
    super.key,
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.currency,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p12, horizontal: AppSpacing.p12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Flexible(child: _PersonChip(name: fromName, isDark: isDark, color: AppColors.activeRed)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p4),
            child: Icon(LucideIcons.arrowRight, size: 14,
                color: isDark ? Colors.grey.shade500 : const Color(0xFF9CA3AF)),
          ),
          Flexible(child: _PersonChip(name: toName, isDark: isDark, color: AppColors.activeGreen)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p4, horizontal: AppSpacing.p8),
            decoration: BoxDecoration(
              color: AppColors.activeGreen.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.r8),
            ),
            child: Text(
              formatAmount(amount, currency),
              style: AppTextStyles.bodySmall.copyWith(fontFamily: GoogleFonts.jetBrainsMono().fontFamily, fontWeight: FontWeight.w800,
                color: AppColors.activeGreen),
            ),
          ),
        ],
      ),
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
          radius: 12,
          backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
          child: Text(
            name.isNotEmpty ? String.fromCharCode(name.runes.first).toUpperCase() : '?',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: color
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s4),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}
