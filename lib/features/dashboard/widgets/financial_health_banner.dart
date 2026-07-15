import 'package:expense_tracker/core/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_font_sizes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FinancialHealthBanner extends StatelessWidget {
  final double percentageChange;
  final String period;

  const FinancialHealthBanner({
    super.key,
    required this.percentageChange,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = percentageChange >= 0;
    final sign = isPositive ? '+' : '';
    final direction = isPositive ? 'increased' : 'decreased';

    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF0C4E3C), const Color(0xFF2EBD85)]
              : [const Color(0xFF8B1A1A), const Color(0xFFDC3545)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -20,
            child: Icon(
              isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
              color: Colors.white.withValues(alpha: 0.08),
              size: 140,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('financial_health'),
                  style: TextStyle(
                    fontSize: AppFontSizes.size15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: TextStyle().fontFamily,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.translate('income_health_change_message')
                      .replaceAll('{direction}', context.translate(direction))
                      .replaceAll('{change}', '$sign${percentageChange.toStringAsFixed(1)}')
                      .replaceAll('{period}', context.translate(period)),
                  style: TextStyle(
                    fontSize: AppFontSizes.size12,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: TextStyle().fontFamily,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
