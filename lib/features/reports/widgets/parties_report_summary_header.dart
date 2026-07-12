import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PartiesReportSummaryHeader extends StatelessWidget {
  final double totalToReceive;
  final double totalToGive;
  final bool isMasked;

  const PartiesReportSummaryHeader({
    super.key,
    required this.totalToReceive,
    required this.totalToGive,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryColumn(
              icon: LucideIcons.arrowDownToLine,
              label: 'To Receive',
              amount: totalToReceive,
              color: theme.primaryColor,
              isMasked: isMasked,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.dividerTheme.color ?? const Color(0xFFF1F1F1),
          ),
          Expanded(
            child: _SummaryColumn(
              icon: LucideIcons.arrowUpFromLine,
              label: 'To Give',
              amount: totalToGive,
              color: Colors.redAccent,
              isMasked: isMasked,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final dynamic icon;
  final String label;
  final double amount;
  final Color color;
  final bool isMasked;

  const _SummaryColumn({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isMasked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.size12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        PrivacyMaskedText(
          amount: amount,
          isMasked: isMasked,
          style: TextStyle(
            fontSize: AppFontSizes.size16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
