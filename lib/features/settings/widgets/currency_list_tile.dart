import 'package:expense_tracker/core/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_text_styles.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CurrencyListTile extends StatelessWidget {
  final CurrencyInfo currency;
  final bool isSelected;
  final bool isCard;
  final VoidCallback onTap;

  const CurrencyListTile({
    super.key,
    required this.currency,
    required this.isSelected,
    this.isCard = false,
    required this.onTap,
  });

  Widget _buildFlagIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Theme.of(context).cardColor : const Color(0xFFF9FAFB),
        border: Border.all(
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        currency.flag,
        style: const TextStyle(
          fontSize: AppFontSizes.size22,
          height: 1.25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeGreenColor = isDark ? const Color(0xFF10B981) : const Color(0xFF064E3B);
    final borderColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB);

    final tile = _buildRowContent(context, theme, isDark, activeGreenColor);

    if (isCard) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: tile,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: tile,
      ),
    );
  }

  Row _buildRowContent(BuildContext context, ThemeData theme, bool isDark, Color activeGreenColor) {
    return Row(
      children: [
        _buildFlagIcon(context),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisAlignment: isCard ? MainAxisAlignment.start : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.name,
                style: AppTextStyles.reportTileTitle.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currency.code,
                style: AppTextStyles.label.copyWith(
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Text(
          currency.symbol,
          style: AppTextStyles.h3.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? activeGreenColor : (isDark ? Colors.grey.shade400 : const Color(0xFF6B7280)),
          ),
        ),
        if (isSelected) ...[
          const SizedBox(width: 14),
          Icon(
            LucideIcons.checkCircle,
            color: activeGreenColor,
            size: 22,
          ),
        ],
      ],
    );
  }
}
