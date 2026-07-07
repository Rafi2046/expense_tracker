import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/privacy_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopSpendingCategoryItem {
  final String title;
  final String subtitle;
  final double amount;
  final double percentage;
  final IconData icon;

  TopSpendingCategoryItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.percentage,
    required this.icon,
  });
}

class TopSpendingCategoryRow extends StatelessWidget {
  final TopSpendingCategoryItem item;
  final bool isMasked;
  final double maxAmount;
  final int index;

  const TopSpendingCategoryRow({
    super.key,
    required this.item,
    this.isMasked = false,
    required this.maxAmount,
    required this.index,
  });

  static const _barColors = [
    Color(0xFF1EA97C),
    Color(0xFF2EBD85),
    Color(0xFF80E2B9),
    Color(0xFFE24361),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  Color get _barColor => _barColors[index % _barColors.length];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final barPct = maxAmount > 0 ? item.amount / maxAmount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _barColor.withValues(alpha: 0.2),
                      _barColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: _barColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: barPct,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: PrivacyMaskedText(
                      amount: item.amount,
                      isMasked: isMasked,
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.activeRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.percentage < 1
                          ? '${item.percentage.toStringAsFixed(1)}%'
                          : '${item.percentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.workSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.activeRed,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
