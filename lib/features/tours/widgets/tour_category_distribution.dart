import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:expense_tracker/features/tours/utils/tour_insights_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_spacing.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';



class TourCategoryDistribution extends StatelessWidget {
  final List<CategoryBreakdownItem> items;
  final double grandTotal;
  final String currency;
  final bool isEmpty;

  const TourCategoryDistribution({
    super.key,
    required this.items,
    required this.grandTotal,
    required this.currency,
    this.isEmpty = false,
  });

  String _symbol(String code) {
    const symbols = {
      'BDT': '\u09F3', 'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3',
      'INR': '\u20B9', 'JPY': '\u00A5', 'AED': '\u062F.\u0625',
      'CAD': r'$',
    };
    return symbols[code] ?? r'$';
  }

  String _compact(double amount) {
    final s = _symbol(currency);
    final nf = NumberFormat.compact();
    return '$s${nf.format(amount)}';
  }

  String _pct(double val) => '${(val * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isEmpty || grandTotal == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.p32),
        child: Center(
          child: Text(
            context.translate('no_expenses_yet'),
            style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.r8),
          child: SizedBox(height: AppSpacing.s12,
            child: Row(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.s4),
                  Expanded(
                    flex: (items[i].percentage * 1000).round().clamp(1, 1000),
                    child: Container(
                        color: _categoryColor(items[i].name, isDark)),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        ...items.map((item) => _buildRow(item, isDark, theme)),
      ],
    );
  }

  Widget _buildRow(CategoryBreakdownItem item, bool isDark, ThemeData theme) {
    final color = _categoryColor(item.name, isDark);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.p16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface),
            ),
          ),
          Text(
            _pct(item.percentage),
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
          ),
          const SizedBox(width: AppSpacing.s12),
          Text(
            _compact(item.amount),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String name, bool isDark) {
    const palette = [
      Color(0xFF32ADE6),
      Color(0xFF34C759),
      Color(0xFFAF52DE),
      Color(0xFFFF2D55),
      Color(0xFFFF9500),
      Color(0xFF64D2FF),
      Color(0xFFFFCC00),
      Color(0xFF5856D6),
      Color(0xFF00C7BE),
      Color(0xFFFF3B30),
    ];
    return palette[name.hashCode % palette.length];
  }
}
