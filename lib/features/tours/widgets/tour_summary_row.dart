import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';


class TourSummaryRow extends StatelessWidget {
  final String totalSpentText;
  final String outstandingText;
  final bool isSettled;

  const TourSummaryRow({
    super.key,
    required this.totalSpentText,
    required this.outstandingText,
    required this.isSettled,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            scheme: scheme,
            label: context.translate('total_spent_card'),
            value: totalSpentText,
            icon: LucideIcons.receipt,
            iconColor: scheme.primary,
            iconBgColor: scheme.primaryContainer,
            valueColor: scheme.onSurface,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: _buildSummaryCard(
            scheme: scheme,
            label: isSettled ? context.translate('all_settled_card') : context.translate('outstanding_card'),
            value: isSettled ? '✓' : outstandingText,
            icon: isSettled ? LucideIcons.checkCircle : LucideIcons.alertCircle,
            iconColor: isSettled ? scheme.primary : scheme.error,
            iconBgColor: isSettled ? scheme.primaryContainer : scheme.errorContainer,
            valueColor: isSettled ? scheme.primary : scheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required ColorScheme scheme,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.r12),
        border: Border.all(
          color: scheme.outline,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.p4),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}
